const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Fine = sequelize.define('Fine', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Users',
        key: 'id',
      },
    },
    borrowingId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'Borrowings',
        key: 'id',
      },
    },
    amount: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      defaultValue: 0.00,
    },
    reason: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    status: {
      type: DataTypes.ENUM('pending', 'paid', 'waived'),
      defaultValue: 'pending',
    },
    fineDate: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    paidDate: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    paidAmount: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 0.00,
    },
  });

  return Fine;
};
