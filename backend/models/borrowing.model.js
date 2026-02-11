const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Borrowing = sequelize.define('Borrowing', {
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
      key: 'id'
    }
  },
  bookId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'Books',
      key: 'id'
    }
  },
  borrowDate: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  dueDate: {
    type: DataTypes.DATE,
    allowNull: false,
    validate: {
      isDate: {
        msg: "Due date is required"
      },
      isAfterToday(value) {
        if (new Date(value) <= new Date()) {
          throw new Error("Due date must be in the future");
        }
      }
    }
  },
  returnDate: {
    type: DataTypes.DATE,
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('active', 'returned', 'overdue'),
    defaultValue: 'active'
  },
  renewalsLeft: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
    validate: {
      min: {
        args: [0],
        msg: "Renewals left cannot be negative"
      }
    }
  },
  isRead: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  readDate: {
    type: DataTypes.DATE,
    allowNull: true
  }
}, {
  indexes: [
    {
      fields: ['userId', 'status']
    },
    {
      fields: ['bookId', 'status']
    },
    {
      fields: ['dueDate']
    }
  ]
});

module.exports = Borrowing;
