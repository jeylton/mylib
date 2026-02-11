const { sequelize, Op } = require('../config/db');
const { User, Book, Borrowing, Reservation, Fine } = require("../models");

// 🎓 Student Dashboard
exports.getStudentDashboard = async (req, res) => {
  const userId = req.params.userId;

  try {
    const borrowings = await Borrowing.findAll({ 
      where: { userId },
      order: [['borrowDate', 'DESC']],
      include: [{ model: Book, as: 'book', attributes: ['title', 'author'] }]
    });
    const reservations = await Reservation.findAll({ 
      where: { userId },
      order: [['reservationDate', 'DESC']],
      include: [{ model: Book, as: 'book', attributes: ['title', 'author'] }]
    });

    const borrowedBooks = borrowings.filter(b => b.status === "active").length;
    const overdueBooks = borrowings.filter(b => b.status === "overdue").length;
    const booksRead = borrowings.filter(b => b.isRead === true).length;

    const activeReservations = reservations.filter(r => r.status === "active").length;

    // Count books read this year
    const currentYear = new Date().getFullYear();
    const readThisYear = borrowings.filter(b => {
      if (!b.returnDate) return false;
      const returnDate = new Date(b.returnDate);
      return b.status === "returned" && returnDate.getFullYear() === currentYear;
    }).length;

    // Get user balance
    const user = await User.findByPk(userId, {
      attributes: ['balance']
    });
    const totalBalance = user ? parseFloat(user.balance) : 2500.00;

    res.json({
      borrowedBooks,
      overdueBooks,
      activeReservations,
      booksRead,
      readThisYear,
      totalBalance,
      recentBorrowings: borrowings.slice(0, 5),
      recentReservations: reservations.slice(0, 5),
    });
  } catch (err) {
    console.error("Error in getStudentDashboard:", err);
    res.status(500).json({ message: err.message });
  }
};

// 👨‍💼 Admin Overview Dashboard
exports.getAdminOverview = async (req, res) => {
  try {
    
    const totalBooks = await Book.count();
    const borrowedBooks = await Book.count({ where: { status: "borrowed" } });
    const reservedBooks = await Book.count({ where: { status: "reserved" } });
    const availableBooks = await Book.count({ where: { status: "available" } });

    const totalUsers = await User.count();
    const totalBorrowings = await Borrowing.count();
    const totalReservations = await Reservation.count();

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const todayBorrowings = await Borrowing.count({
      where: {
        borrowDate: { [Op.gte]: today },
      },
    });

    const todayReturns = await Borrowing.count({
      where: {
        returnDate: { [Op.gte]: today },
      },
    });

    const todayOverdue = await Borrowing.count({
      where: {
        dueDate: { [Op.lt]: new Date() },
        status: "active",
      },
    });

    const popularBooks = await Book.findAll({
      order: [['borrowCount', 'DESC']],
      limit: 5,
      attributes: ['title', 'borrowCount'],
    });

    // Stats des amendes
    const totalFines = await Fine.sum('amount');
    const paidFines = await Fine.sum('paidAmount', { where: { status: 'paid' } });
    const pendingFines = await Fine.sum('amount', { where: { status: 'pending' } });
    const totalBalanceCollected = paidFines || 0;

    res.json({
      totalBooks,
      borrowedBooks,
      reservedBooks,
      availableBooks,
      totalUsers,
      totalBorrowings,
      totalReservations,
      todayBorrowings,
      todayReturns,
      todayOverdue,
      popularBooks,
      // Stats des amendes
      totalFines: totalFines || 0,
      paidFines: paidFines || 0,
      pendingFines: pendingFines || 0,
      totalBalanceCollected,
    });
  } catch (err) {
    console.error("Error in getAdminOverview:", err);
    res.status(500).json({ message: err.message });
  }
};

// 📊 Admin Analytics
exports.getAdminAnalytics = async (req, res) => {
  try {
    const { sequelize } = require('../config/db');
    const startOfYear = new Date(new Date().getFullYear(), 0, 1);
    const monthlyData = Array(12).fill(0);

    const monthlyBorrowings = await Borrowing.findAll({
      where: {
        borrowDate: { [sequelize.Op.gte]: startOfYear },
      },
    });

    monthlyBorrowings.forEach(b => {
      const month = new Date(b.borrowDate).getMonth(); // 0 = January
      monthlyData[month]++;
    });

    res.json({
      monthlyBorrowingTrend: monthlyData,
    });
  } catch (err) {
    console.error("Error in getAdminAnalytics:", err);
    res.status(500).json({ message: err.message });
  }
};

// 🏆 Top Borrowers
exports.getTopBorrowers = async (req, res) => {
  try {
    const { sequelize } = require('../config/db');
    
    const topBorrowers = await Borrowing.findAll({
      attributes: [
        'userId',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['userId', 'User.id'],
      order: [[sequelize.literal('count'), 'DESC']],
      limit: 5,
      include: [{
        model: User,
        attributes: ['name', 'email'],
      }],
    });

    res.status(200).json(topBorrowers);
  } catch (err) {
    console.error("Error fetching top borrowers:", err);
    res.status(500).json({ message: "Failed to fetch top borrowers" });
  }
};
