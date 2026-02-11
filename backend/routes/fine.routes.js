const express = require("express");
const router = express.Router();
const fineController = require("../controllers/fine.controller");
const { protect, authorize } = require("../middleware/auth.middleware");

// Routes admin
router.get("/all", protect, authorize("admin"), fineController.getAllFines);
router.get("/stats", protect, authorize("admin"), fineController.getFineStats);
router.post("/calculate-overdue", protect, authorize("admin"), fineController.calculateOverdueFines);
router.post("/update-all-balances", protect, authorize("admin"), fineController.updateAllUserBalances);

// Routes étudiant (student)
router.get("/user/:userId", protect, fineController.getUserFines);
router.get("/balance/:userId", protect, fineController.getUserBalance);
router.post("/pay/:fineId", protect, fineController.payFine);
router.post("/add-balance/:userId", protect, fineController.addBalance);

module.exports = router;
