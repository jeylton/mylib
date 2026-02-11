const User = require('../models/user.model');

// Vérifier le balance d'un utilisateur par email
exports.checkUserBalanceByEmail = async (req, res) => {
  try {
    const { email } = req.params;
    
    const user = await User.findOne({
      where: { email },
      attributes: ['id', 'name', 'email', 'role', 'balance']
    });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({
      user: user,
      message: `Balance de ${user.name}: ${user.balance}F`
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
