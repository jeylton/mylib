const { sequelize } = require('../config/db');
const User = require('./user.model');
const Book = require('./book.model');
const Borrowing = require('./borrowing.model');
const Reservation = require('./reservation.model');
const Fine = require('./fine.model')(sequelize);

// Définir les associations
User.hasMany(Book, { foreignKey: 'addedBy', as: 'addedBooks' });
Book.belongsTo(User, { foreignKey: 'addedBy', as: 'addedByUser' });

User.hasMany(Book, { foreignKey: 'currentBorrower', as: 'borrowedBooks' });
Book.belongsTo(User, { foreignKey: 'currentBorrower', as: 'currentBorrowerUser' });

User.hasMany(Borrowing, { foreignKey: 'userId', as: 'borrowings' });
Borrowing.belongsTo(User, { foreignKey: 'userId', as: 'user' });

Book.hasMany(Borrowing, { foreignKey: 'bookId', as: 'borrowings' });
Borrowing.belongsTo(Book, { foreignKey: 'bookId', as: 'book' });

User.hasMany(Reservation, { foreignKey: 'userId', as: 'reservations' });
Reservation.belongsTo(User, { foreignKey: 'userId', as: 'user' });

Book.hasMany(Reservation, { foreignKey: 'bookId', as: 'reservations' });
Reservation.belongsTo(Book, { foreignKey: 'bookId', as: 'book' });

// Associations pour les amendes
User.hasMany(Fine, { foreignKey: 'userId', as: 'fines' });
Fine.belongsTo(User, { foreignKey: 'userId', as: 'user' });

Borrowing.hasMany(Fine, { foreignKey: 'borrowingId', as: 'fines' });
Fine.belongsTo(Borrowing, { foreignKey: 'borrowingId', as: 'borrowing' });

module.exports = {
  sequelize,
  User,
  Book,
  Borrowing,
  Reservation,
  Fine
};
