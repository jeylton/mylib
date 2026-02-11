const cron = require("node-cron");
const { Reservation, Borrowing, User, Book } = require("../models");
const { Op } = require("sequelize");
const sendEmail = require("../services/mail.service");

if (process.env.ENABLE_CRON === "true") {
  console.log("🔁 Cron jobs enabled");

  // ⏰ Expire reservations every 30 minutes
  cron.schedule("*/30 * * * *", async () => {
    try {
      console.log("⏰ [Reservation] Checking for expired reservations...");
      const now = new Date();

      const expired = await Reservation.findAll({
        where: {
          expirationDate: { [Op.lt]: now },
          status: "active",
        },
        include: [
          { association: 'user' },
          { association: 'book' }
        ]
      });

      for (const r of expired) {
        await r.update({ status: "expired" });

        await sendEmail(
          r.user.email,
          "Reservation Expired",
          `Your reservation for "${r.book.title}" has expired and is no longer valid.`
        );
      }

      console.log(`✅ [Reservation] ${expired.length} expired and notified.`);
    } catch (err) {
      console.error("❌ [Reservation] Cron error:", err.message);
    }
  });

  // ⏰ Check overdue borrowings every night at 00:30
  cron.schedule("30 0 * * *", async () => {
    try {
      console.log("⏰ [Borrowing] Checking for overdue books...");
      const now = new Date();

      const overdue = await Borrowing.findAll({
        where: {
          dueDate: { [Op.lt]: now },
          status: "active",
        },
        include: [
          { association: 'user' },
          { association: 'book' }
        ]
      });

      for (const b of overdue) {
        await b.update({ status: "overdue" });

        await sendEmail(
          b.user.email,
          "Book Overdue Notice",
          `The book "${b.book.title}" you borrowed is now overdue. Please return it immediately to avoid penalties.`
        );
      }

      console.log(`📢 [Borrowing] ${overdue.length} overdue notices sent.`);
    } catch (err) {
      console.error("❌ [Borrowing] Cron error:", err.message);
    }
  });
} else {
  console.log("⚠️ Cron jobs disabled via .env");
}
