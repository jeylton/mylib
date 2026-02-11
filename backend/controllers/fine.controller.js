const Fine = require("../models/fine.model");
const User = require("../models/user.model");
const Borrowing = require("../models/borrowing.model");
const { Op } = require("sequelize");

// 🏦 Gestion des amendes
exports.getAllFines = async (req, res) => {
  try {
    const fines = await Fine.findAll({
      include: [
        { model: User, attributes: ['name', 'email'] },
        { model: Borrowing, include: [{ model: require('../models/book.model'), attributes: ['title'] }] }
      ],
      order: [['fineDate', 'DESC']]
    });

    res.json(fines);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getUserFines = async (req, res) => {
  try {
    const userId = req.params.userId;
    const fines = await Fine.findAll({
      where: { userId },
      include: [
        { model: Borrowing, include: [{ model: require('../models/book.model'), attributes: ['title'] }] }
      ],
      order: [['fineDate', 'DESC']]
    });

    res.json(fines);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.createFine = async (req, res) => {
  try {
    const { userId, borrowingId, amount, reason } = req.body;

    const fine = await Fine.create({
      userId,
      borrowingId,
      amount,
      reason,
      status: 'pending'
    });

    res.status(201).json(fine);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.payFine = async (req, res) => {
  try {
    const fineId = req.params.id;
    const { paidAmount } = req.body;

    const fine = await Fine.findByPk(fineId);
    if (!fine) {
      return res.status(404).json({ message: "Fine not found" });
    }

    if (fine.status === 'paid') {
      return res.status(400).json({ message: "Fine already paid" });
    }

    const user = await User.findByPk(fine.userId);
    if (user.balance < paidAmount) {
      return res.status(400).json({ message: "Insufficient balance" });
    }

    // Mettre à jour le solde de l'utilisateur
    user.balance -= paidAmount;
    await user.save();

    // Mettre à jour l'amende
    fine.status = 'paid';
    fine.paidAmount = paidAmount;
    fine.paidDate = new Date();
    await fine.save();

    res.json({ message: "Fine paid successfully", fine, newBalance: user.balance });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.addBalance = async (req, res) => {
  try {
    const { userId, amount } = req.body;

    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    user.balance += parseFloat(amount);
    await user.save();

    res.json({ message: "Balance added successfully", newBalance: user.balance });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getUserBalance = async (req, res) => {
  try {
    const userId = req.params.userId;
    const user = await User.findByPk(userId, {
      attributes: ['id', 'name', 'balance']
    });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🤖 Calcul automatique des amendes pour retards
exports.calculateOverdueFines = async (req, res) => {
  try {
    const overdueBorrowings = await Borrowing.findAll({
      where: {
        status: 'active',
        dueDate: { [Op.lt]: new Date() }
      },
      include: [
        { model: User },
        { model: require('../models/book.model'), attributes: ['title'] }
      ]
    });

    const newFines = [];
    const overdueFineAmount = 500; // 500 francs fixe par livre en retard

    for (const borrowing of overdueBorrowings) {
      // Vérifier si une amende existe déjà pour cet emprunt
      const existingFine = await Fine.findOne({
        where: {
          userId: borrowing.userId,
          borrowingId: borrowing.id,
          status: 'pending'
        }
      });

      if (!existingFine) {
        const daysOverdue = Math.ceil((new Date() - borrowing.dueDate) / (1000 * 60 * 60 * 24));
        const fineAmount = overdueFineAmount; // Pénalité fixe de 500F

        const fine = await Fine.create({
          userId: borrowing.userId,
          borrowingId: borrowing.id,
          amount: fineAmount,
          reason: `Retard de ${daysOverdue} jour(s) pour le livre "${borrowing.book.title}" - Pénalité fixe de 500F`,
          status: 'pending'
        });

        newFines.push(fine);
      }
    }

    res.json({ 
      message: "Overdue fines calculated", 
      newFines: newFines.length,
      fines: newFines 
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 📊 Statistiques des amendes pour admin
exports.getFineStats = async (req, res) => {
  try {
    const totalFines = await Fine.sum('amount');
    const paidFines = await Fine.sum('paidAmount', { where: { status: 'paid' } });
    const pendingFines = await Fine.sum('amount', { where: { status: 'pending' } });
    const totalFinesCount = await Fine.count();
    const paidFinesCount = await Fine.count({ where: { status: 'paid' } });
    const pendingFinesCount = await Fine.count({ where: { status: 'pending' } });

    res.json({
      totalAmount: totalFines || 0,
      paidAmount: paidFines || 0,
      pendingAmount: pendingFines || 0,
      totalCount: totalFinesCount,
      paidCount: paidFinesCount,
      pendingCount: pendingFinesCount
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// 🔄 Mettre à jour tous les balances des étudiants (sauf admin)
exports.updateAllUserBalances = async (req, res) => {
  try {
    const { sequelize } = require('../config/db');
    
    // Mettre à jour tous les utilisateurs sauf les admins
    const [updatedCount] = await User.update(
      { balance: 2500.00 },
      { 
        where: { 
          role: { [sequelize.Sequelize.Op.ne]: 'admin' } // role != 'admin'
        }
      }
    );

    // Vérifier les admins pour s'assurer qu'ils n'ont pas de balance
    const adminCount = await User.count({
      where: { role: 'admin' }
    });

    res.json({ 
      message: "Balances mis à jour avec succès",
      studentsUpdated: updatedCount,
      adminCount: adminCount,
      balanceAmount: 2500.00
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
