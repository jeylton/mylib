const { Reservation, Book, User, Borrowing } = require("../models");
const { Op } = require("sequelize");
const { sendEmail } = require("../services/mail.service");

// POST: Reserve a book
exports.reserveBook = async (req, res) => {
  const userId = req.user.id;
  const { bookId } = req.body;

  try {
    const book = await Book.findByPk(bookId);
    if (!book) return res.status(404).json({ message: "Book not found" });

    const alreadyReserved = await Reservation.findOne({ 
      where: { userId, bookId, status: "active" } 
    });
    if (alreadyReserved)
      return res.status(400).json({ message: "You already have an active reservation" });

    const count = await Reservation.count({ where: { bookId, status: "active" } });

    const expiration = new Date();
    expiration.setDate(expiration.getDate() + 2); // 48h expiration

    const reservation = await Reservation.create({
      userId,
      bookId,
      expirationDate: expiration,
      priority: count + 1,
      status: "active",
    });

    await book.update({
      reservationCount: (book.reservationCount || 0) + 1
    });

    const user = await User.findByPk(userId);
    await sendEmail(
      user.email,
      "Reservation Confirmed",
      `Your reservation for "${book.title}" was successful. You have 48h to pick it up.`
    );

    const populated = await Reservation.findByPk(reservation.id, {
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
      status: populated.status,
      reservationDate: populated.reservationDate?.toISOString(),
      expirationDate: populated.expirationDate?.toISOString(),
      priority: populated.priority,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET: User reservations
exports.getUserReservations = async (req, res) => {
  try {
    const reservations = await Reservation.findAll({
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
      order: [['reservationDate', 'DESC']]
    });

    const result = reservations.map((r) => ({
      id: r.id,
      book: r.book,
      user: r.user,
      status: r.status,
      reservationDate: r.reservationDate?.toISOString(),
      expirationDate: r.expirationDate?.toISOString(),
      priority: r.priority,
    }));

    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// PUT: Cancel a reservation
exports.cancelReservation = async (req, res) => {
  try {
    const reservation = await Reservation.findByPk(req.params.id);
    if (!reservation) return res.status(404).json({ message: "Reservation not found" });

    if (reservation.status !== "active")
      return res.status(400).json({ message: "Cannot cancel this reservation" });

    await reservation.update({ status: "cancelled" });

    res.json({ message: "Reservation cancelled" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// PUT: Fulfill reservation
exports.fulfillReservation = async (req, res) => {
  try {
    const reservation = await Reservation.findByPk(req.params.id, {
      include: [
        { association: 'user' },
        { association: 'book' }
      ]
    });
    
    if (!reservation || reservation.status !== 'active') 
      return res.status(400).json({ error: 'Invalid reservation' });

    // Create borrowing
    const borrowing = await Borrowing.create({
      bookId: reservation.bookId,
      userId: reservation.userId,
      borrowDate: new Date(),
      dueDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
      status: 'active'
    });

    // Update book status
    await reservation.book.update({
      status: "borrowed",
      currentBorrower: reservation.userId,
      borrowCount: reservation.book.borrowCount + 1
    });

    await reservation.update({ status: 'fulfilled' });

    // Notify user
    await sendEmail(
      reservation.user.email,
      'Reservation fulfilled',
      `Your reservation for "${reservation.book.title}" is now checked out to you. Due date: ${borrowing.dueDate.toLocaleDateString()}`
    );

    res.json({ success: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
};

// PUT: Expire old reservations and notify users
exports.expireOldReservations = async (req, res) => {
  try {
    const now = new Date();
    const expiredReservations = await Reservation.findAll({
      where: {
        expirationDate: { [Op.lt]: now },
        status: "active",
      },
      include: [
        { association: 'user' },
        { association: 'book' }
      ]
    });

    let count = 0;

    for (const reservation of expiredReservations) {
      await reservation.update({ status: "expired" });

      await sendEmail(
        reservation.user.email,
        "Reservation Expired",
        `Your reservation for "${reservation.book.title}" has expired and is no longer valid.`
      );

      count++;
    }

    res.json({ message: `${count} reservations expired and users notified.` });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET: Queue for a specific book
exports.getBookQueue = async (req, res) => {
  try {
    const queue = await Reservation.findAll({
      where: { bookId: req.params.bookId, status: "active" },
      order: [['priority', 'ASC']],
      include: [
        {
          association: 'user',
          attributes: ['name', 'email']
        },
        {
          association: 'book',
          attributes: ['title', 'author']
        }
      ]
    });

    const result = queue.map((r) => ({
      id: r.id,
      user: r.user,
      book: r.book,
      priority: r.priority,
      status: r.status,
      expirationDate: r.expirationDate,
      reservationDate: r.reservationDate,
    }));

    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// GET: All reservations (admin)
exports.getAllReservations = async (req, res) => {
  try {
    const reservations = await Reservation.findAll({
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
      order: [['reservationDate', 'DESC']]
    });

    const result = reservations.map((r) => ({
      id: r.id,
      book: r.book,
      user: r.user,
      status: r.status,
      reservationDate: r.reservationDate?.toISOString(),
      expirationDate: r.expirationDate?.toISOString(),
      priority: r.priority,
    }));

    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
