const express = require("express");
const { sendTestEmail, sendTestReminder, sendOverdueReminders } = require("../controllers/notification.controller");
const { protect, authorize } = require("../middleware/auth.middleware");

const router = express.Router();

// Routes publiques pour les tests
router.get("/test", sendTestEmail);
router.get("/reminder", sendTestReminder);

// Route protégée pour envoyer des rappels de retard (admin)
router.post("/send-overdue-reminders", protect, authorize("admin"), sendOverdueReminders);

module.exports = router;
