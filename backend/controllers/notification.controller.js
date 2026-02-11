const { sendEmail, sendOverdueReminder } = require("../services/mail.service");
const User = require("../models/user.model");
const Borrowing = require("../models/borrowing.model");
const Book = require("../models/book.model");
const { Op } = require("sequelize");

// Simple test endpoint to send a generic email
exports.sendTestEmail = async (req, res) => {
  try {
    await sendEmail(
      "test@example.com", // You can change this to your test email
      "📢 Test Notification",
      "This is a test notification sent from the Library system."
    );
    res.json({ message: "Test email sent successfully!" });
  } catch (error) {
    console.error("❌ Error sending test email:", error);
    res.status(500).json({ message: "Failed to send test email." });
  }
};

// Another test for overdue reminder email
exports.sendTestReminder = async (req, res) => {
  try {
    await sendOverdueReminder(
      "student@example.com",        // Replace with a real/test email
      "John Doe",                   // Student's name
      "Introduction to AI",         // Book title
      new Date("2025-07-01")        // Due date
    );
    res.json({ message: "Test reminder email sent." });
  } catch (error) {
    console.error("❌ Error sending reminder:", error);
    res.status(500).json({ message: "Failed to send reminder." });
  }
};

// 📧 Envoyer des rappels pour les retards
exports.sendOverdueReminders = async (req, res) => {
  try {
    // Récupérer tous les emprunts en retard
    const overdueBorrowings = await Borrowing.findAll({
      where: {
        status: 'active',
        dueDate: { [Op.lt]: new Date() }
      },
      include: [
        { 
          model: User, 
          attributes: ['name', 'email'] 
        },
        { 
          model: Book, 
          attributes: ['title', 'author'] 
        }
      ]
    });

    if (overdueBorrowings.length === 0) {
      return res.json({ 
        message: "No overdue borrowings found", 
        sent: 0 
      });
    }

    let sentCount = 0;
    const errors = [];

    for (const borrowing of overdueBorrowings) {
      try {
        const daysOverdue = Math.ceil((new Date() - borrowing.dueDate) / (1000 * 60 * 60 * 24));
        
        await sendOverdueReminder(
          borrowing.User.email,
          borrowing.User.name,
          borrowing.Book.title,
          borrowing.dueDate,
          daysOverdue
        );
        sentCount++;
        
      } catch (emailError) {
        errors.push({
          userId: borrowing.userId,
          bookTitle: borrowing.Book.title,
          error: emailError.message
        });
      }
    }

    res.json({ 
      message: "Overdue reminders sent successfully", 
      sent: sentCount,
      total: overdueBorrowings.length,
      errors: errors.length > 0 ? errors : null
    });

  } catch (err) {
    console.error("Error sending overdue reminders:", err);
    res.status(500).json({ message: "Failed to send reminders" });
  }
};
