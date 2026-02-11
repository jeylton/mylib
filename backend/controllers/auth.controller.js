const { User } = require("../models");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const sendEmail = require("../services/mail.service");

// LOGIN
exports.login = async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ where: { email } });

    if (!user)
      return res.status(400).json({ message: "Invalid email or password" });

    // 🔒 Email verification disabled temporarily
    // if (!user.emailVerified) {
    //   return res.status(403).json({
    //     message: "Please verify your email before logging in.",
    //   });
    // }

    // 🔒 TEMPORAIRE : Comparaison directe pour Docker
    const isMatch = password === user.password;
    if (!isMatch)
      return res.status(400).json({ message: "Invalid email or password" });

    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// RESEND EMAIL VERIFICATION — 🔒 Currently disabled
exports.resendVerification = async (req, res) => {
  return res
    .status(200)
    .json({ message: "Email verification is currently disabled." });
};

// REGISTER
exports.register = async (req, res) => {
  const { name, email, password, role } = req.body;

  try {
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) return res.status(400).json({ message: "Email already exists" });

    const user = await User.create({ name, email, password, role });

    res.status(201).json({ message: "User registered successfully." });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// VERIFY EMAIL — 🔒 Currently disabled
exports.verifyEmail = async (req, res) => {
  return res
    .status(200)
    .json({ message: "Email verification is currently disabled." });
};

// FORGOT PASSWORD
exports.forgotPassword = async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ where: { email } });
    if (!user) return res.status(404).json({ message: "User not found" });

    const resetToken = crypto.randomBytes(32).toString("hex");
    const hashedToken = crypto.createHash("sha256").update(resetToken).digest("hex");

    user.passwordResetToken = hashedToken;
    user.passwordResetExpires = new Date(Date.now() + 1000 * 60 * 30); // 30 minutes
    await user.save();

    const resetUrl = `${process.env.CLIENT_URL}/reset-password/${resetToken}`;
    await sendEmail(
      user.email,
      "Password Reset Request",
      `To reset your password, click this link:\n${resetUrl}\nThis link will expire in 30 minutes.`
    );

    res.json({ message: "Password reset email sent." });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// UPDATE USER PROFILE
exports.updateUserProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const { name, email, password } = req.body;

    const user = await User.findByPk(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    const updateData = {};
    if (name) updateData.name = name;

    if (email && email !== user.email) {
      const existing = await User.findOne({ where: { email } });
      if (existing) {
        return res.status(400).json({ message: "Email already in use" });
      }
      updateData.email = email;
    }

    if (password && password.length >= 6) {
      updateData.password = password;
    }

    await user.update(updateData);

    res.json({
      message: "Profile updated successfully",
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// RESET PASSWORD
exports.resetPassword = async (req, res) => {
  const { token } = req.params;
  const { password } = req.body;

  try {
    const hashedToken = crypto.createHash("sha256").update(token).digest("hex");

    const user = await User.findOne({
      where: {
        passwordResetToken: hashedToken,
        passwordResetExpires: { [require('sequelize').Op.gt]: new Date() },
      },
    });

    if (!user) return res.status(400).json({ message: "Invalid or expired token" });

    await user.update({
      password: password,
      passwordResetToken: null,
      passwordResetExpires: null,
    });

    res.json({ message: "Password reset successful" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
