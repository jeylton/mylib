const express = require("express");
const router = express.Router();
const debugController = require("../controllers/debug.controller");
const { protect, authorize } = require("../middleware/auth.middleware");

// Route admin pour debugger
router.get("/user-balance/:email", protect, authorize("admin"), debugController.checkUserBalanceByEmail);

module.exports = router;
