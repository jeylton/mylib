const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Book = sequelize.define('Book', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      notEmpty: {
        msg: "Title is required"
      }
    }
  },
  author: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      notEmpty: {
        msg: "Author is required"
      }
    }
  },
  genre: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      notEmpty: {
        msg: "Genre is required"
      }
    }
  },
  isbn: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
    validate: {
      notEmpty: {
        msg: "ISBN is required"
      }
    }
  },
  barcode: {
    type: DataTypes.STRING,
    allowNull: true,
    unique: true,
    validate: {
      notEmpty: {
        msg: "Barcode cannot be empty if provided"
      }
    }
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1,
    validate: {
      min: {
        args: [1],
        msg: "Quantity must be at least 1"
      }
    }
  },
  borrowedCount: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    validate: {
      min: {
        args: [0],
        msg: "Borrowed count cannot be negative"
      }
    }
  },
  coverImagePath: {
    type: DataTypes.STRING,
    defaultValue: ""
  },
  status: {
    type: DataTypes.ENUM('available', 'borrowed', 'reserved'),
    defaultValue: 'available'
  },
  addedBy: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'Users',
      key: 'id'
    }
  },
  currentBorrower: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'Users',
      key: 'id'
    }
  },
  reservationCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  totalCopies: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1,
    validate: {
      min: {
        args: [1],
        msg: "Total copies must be at least 1"
      }
    }
  },
  availableCopies: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1,
    validate: {
      min: {
        args: [0],
        msg: "Available copies cannot be negative"
      }
    }
  },
  nextAvailableDate: {
    type: DataTypes.DATE,
    allowNull: true
  },
  borrowCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
}, {
  hooks: {
    beforeCreate: (book) => {
      // S'assurer que availableCopies = totalCopies à la création
      if (book.availableCopies === undefined) {
        book.availableCopies = book.totalCopies;
      }
    },
    beforeUpdate: (book) => {
      // Mettre à jour le status selon les copies disponibles
      if (book.availableCopies <= 0) {
        book.status = 'borrowed';
      } else if (book.availableCopies < book.totalCopies) {
        book.status = 'borrowed'; // Au moins une copie empruntée
      } else {
        book.status = 'available';
      }
    }
  },
  indexes: [
    {
      unique: true,
      fields: ['isbn']
    },
    {
      fields: ['title', 'author', 'genre']
    }
  ]
});

module.exports = Book;
