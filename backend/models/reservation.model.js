const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Reservation = sequelize.define('Reservation', {
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
  reservationDate: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  expirationDate: {
    type: DataTypes.DATE,
    allowNull: true,
    validate: {
      isAfterReservation(value) {
        if (value && new Date(value) <= new Date(this.reservationDate)) {
          throw new Error("Expiration date must be after reservation date");
        }
      }
    }
  },
  status: {
    type: DataTypes.ENUM('active', 'fulfilled', 'expired', 'cancelled'),
    defaultValue: 'active'
  },
  priority: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: {
        args: [1],
        msg: "Priority must be at least 1"
      }
    }
  },
  notificationSent: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
}, {
  indexes: [
    {
      fields: ['bookId', 'status', 'priority']
    },
    {
      fields: ['userId', 'status']
    },
    {
      fields: ['expirationDate']
    }
  ]
});

module.exports = Reservation;
