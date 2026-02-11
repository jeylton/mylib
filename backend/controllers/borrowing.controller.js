const { Borrowing, Book, Reservation, User } = require("../models");
const { Op } = require("sequelize");
const { sendEmail, sendOverdueReminder } = require("../services/mail.service");

// POST: Borrow a book
exports.borrowBook = async (req, res) => {
  const userId = req.user.id;
  const { bookId } = req.body;
  try {
    const book = await Book.findByPk(bookId);
    if (!book) return res.status(404).json({ message: "Book not found" });
    
    const availableCount = (book.quantity || 1) - (book.borrowedCount || 0);
    if (availableCount <= 0)
      return res.status(400).json({ message: "No copies available" });

    const dueDate = new Date();
    dueDate.setDate(dueDate.getDate() + 14); // 2 semaines

    const borrowing = await Borrowing.create({ userId, bookId, dueDate });

    // Mettre à jour le stock du livre
    await book.update({
      borrowedCount: (book.borrowedCount || 0) + 1
    });

    const populated = await Borrowing.findByPk(borrowing.id, {
      include: [
        {
          association: 'book',
          attributes: ['title', 'author']
        },
        {
          association: 'user',
          attributes: ['name', 'email']
        }
      ]
    });

    res.status(201).json({
      id: populated.id,
      book: populated.book,
      user: populated.user,
      borrowDate: populated.borrowDate?.toISOString(),
      dueDate: populated.dueDate?.toISOString(),
      returnDate: populated.returnDate?.toISOString() || null,
      status: populated.status,
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

// PUT: Return a book
exports.returnBook = async (req, res) => {
  try {
    const borrowing = await Borrowing.findByPk(req.params.id);
    if (!borrowing || borrowing.status !== "active") 
      return res.status(400).json({ error: "Invalid borrowing" });

    await borrowing.update({
      status: "returned",
      returnDate: new Date()
    });

    const book = await Book.findByPk(borrowing.bookId);
    if (!book) return res.status(404).json({ error: "Book not found" });

    // Diminuer le nombre d'exemplaires empruntés
    await book.update({
      borrowedCount: Math.max(0, (book.borrowedCount || 0) - 1)
    });

    const nextReservation = await Reservation.findOne({
      where: {
        bookId: borrowing.bookId,
        status: 'active'
      },
      order: [['reservationDate', 'ASC']]
    });

    if (nextReservation && book.availableCopies > 0) {
      const newBorrowing = await Borrowing.create({
        bookId: nextReservation.bookId,
        userId: nextReservation.userId,
        borrowDate: new Date(),
        dueDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
        status: "active",
      });

      // Diminuer à nouveau le stock pour la réservation automatique
      await book.update({
        availableCopies: book.availableCopies - 1,
        currentBorrower: nextReservation.userId
      });

      await nextReservation.update({ status: "fulfilled" });

      const user = await User.findByPk(nextReservation.userId);

      await sendEmail(
        user.email,
        "Your reserved book is now available",
        `Hi ${user.name}, the book "${book.title}" was just returned and is now yours. Due: ${newBorrowing.dueDate.toLocaleDateString()}`
      );
    }

    res.json({ success: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
};

// PUT: Renew a book
exports.renewBook = async (req, res) => {
  try {
    const borrowing = await Borrowing.findByPk(req.params.id);
    if (!borrowing || borrowing.status !== "active")
      return res.status(400).json({ message: "Invalid or inactive borrowing" });

    if (borrowing.renewalsLeft <= 0)
      return res.status(400).json({ message: "No renewals left" });

    const newDueDate = new Date(borrowing.dueDate);
    newDueDate.setDate(newDueDate.getDate() + 14);

    await borrowing.update({
      dueDate: newDueDate,
      renewalsLeft: borrowing.renewalsLeft - 1
    });

    res.json({
      message: "Book renewed successfully",
      newDueDate: newDueDate.toISOString(),
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

// PUT: Mark a book as read (without returning it)
exports.markAsRead = async (req, res) => {
  try {
    const borrowing = await Borrowing.findByPk(req.params.id, {
      include: [{ model: require('../models/book.model'), as: 'book' }]
    });

    if (!borrowing) {
      return res.status(404).json({ message: "Borrowing not found" });
    }

    if (borrowing.status !== 'active') {
      return res.status(400).json({ message: "Book is not currently borrowed" });
    }

    // Add a new field to track if the book has been read
    await borrowing.update({
      isRead: true,
      readDate: new Date()
    });

    res.json({
      message: "Book marked as read successfully",
      readDate: new Date()
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
};

// GET: Borrowings of a user
exports.getUserBorrowings = async (req, res) => {
  try {
    const borrowings = await Borrowing.findAll({
      where: { userId: req.params.userId },
      include: [
        {
          association: 'book',
          attributes: ['title', 'author']
        },
        {
          association: 'user',
          attributes: ['name', 'email']
        }
      ],
      order: [['borrowDate', 'DESC']]
    });

    const result = borrowings.map((b) => ({
      id: b.id,
      book: b.book,
      user: b.user,
      borrowDate: b.borrowDate?.toISOString(),
      returnDate: b.returnDate?.toISOString() || null,
      dueDate: b.dueDate?.toISOString(),
      status: b.status,
    }));

    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET: All borrowings (admin)
exports.getAllBorrowings = async (req, res) => {
  try {
    const borrowings = await Borrowing.findAll({
      include: [
        { association: 'book' },
        { association: 'user' }
      ],
      order: [['borrowDate', 'DESC']]
    });

    const formatted = borrowings.map((b) => ({
      id: b.id,
      book: b.book,
      user: b.user,
      borrowDate: b.borrowDate?.toISOString(),
      returnDate: b.returnDate?.toISOString() || null,
      dueDate: b.dueDate?.toISOString(),
      status: b.status,
    }));

    res.json(formatted);
  } catch (err) {
    res.status(500).json({ message: "Server error" });
  }
};

// GET: Overdue borrowings
exports.getOverdueBorrowings = async (req, res) => {
  try {
    const now = new Date();
    const overdueBorrowings = await Borrowing.findAll({
      where: {
        dueDate: { [Op.lt]: now },
        status: "active"
      },
      include: [
        {
          association: 'book',
          attributes: ['title']
        },
        {
          association: 'user',
          attributes: ['name', 'email']
        }
      ]
    });

    const result = overdueBorrowings.map((b) => ({
      bookTitle: b.book.title,
      userName: b.user.name,
      userEmail: b.user.email,
      dueDate: b.dueDate?.toISOString(),
    }));

    res.json(result);
  } catch (e) {
    res.status(500).json({ message: "Server error" });
  }
};

// POST: Send email reminders
exports.sendOverdueReminders = async (req, res) => {
  try {
    const now = new Date();
    const overdueBorrowings = await Borrowing.findAll({
      where: {
        dueDate: { [Op.lt]: now },
        status: "active"
      },
      include: [
        {
          association: 'book',
          attributes: ['title']
        },
        {
          association: 'user',
          attributes: ['name', 'email']
        }
      ]
    });

    for (const borrowing of overdueBorrowings) {
      await sendOverdueReminder(
        borrowing.user.email, 
        borrowing.user.name, 
        borrowing.book.title, 
        borrowing.dueDate
      );
    }

    res.json({ message: `Sent ${overdueBorrowings.length} reminder emails.` });
  } catch (e) {
    res.status(500).json({ message: "Failed to send reminders" });
  }
};
