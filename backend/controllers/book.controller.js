const { Book } = require("../models");
const { Op } = require("sequelize");
const fs = require("fs");
const path = require("path");

// GET all books with pagination and search
exports.getBooks = async (req, res) => {
  const { page = 1, limit = 10, search = "", genre, author, status } = req.query;
  const where = {};

  if (search) {
    where[Op.or] = [
      { title: { [Op.iLike]: `%${search}%` } },
      { author: { [Op.iLike]: `%${search}%` } },
      { genre: { [Op.iLike]: `%${search}%` } },
      { barcode: { [Op.iLike]: `%${search}%` } }
    ];
  }
  if (genre) where.genre = genre;
  if (author) where.author = author;
  if (status) where.status = status;

  try {
    const offset = (page - 1) * limit;
    
    const { count, rows: books } = await Book.findAndCountAll({
      where,
      offset,
      limit: Number(limit),
      order: [['createdAt', 'DESC']],
      include: [
        {
          association: 'addedByUser',
          attributes: ['id', 'name']
        }
      ]
    });

    res.json({ 
      total: count, 
      page: Number(page), 
      limit: Number(limit), 
      books 
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// DELETE a book
exports.deleteBook = async (req, res) => {
  try {
    const book = await Book.findByPk(req.params.id);
    
    if (!book) {
      return res.status(404).json({ message: "Book not found" });
    }

    // Supprimer l'image de couverture si elle existe
    if (book.coverImagePath && book.coverImagePath !== "") {
      const imagePath = path.join(__dirname, '..', 'uploads', book.coverImagePath);
      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath);
      }
    }

    await book.destroy();
    res.json({ message: "Book deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Helper: Save base64 image
const saveBase64Image = (base64String) => {
  const matches = base64String.match(/^data:(.+);base64,(.+)$/);
  const buffer = Buffer.from(matches ? matches[2] : base64String, "base64");
  const fileName = `book-${Date.now()}.png`;
  const filePath = path.join(__dirname, "..", "uploads", fileName);
  fs.writeFileSync(filePath, buffer);
  return `/uploads/${fileName}`;
};

// GET book by ID
exports.getBookById = async (req, res) => {
  try {
    const book = await Book.findByPk(req.params.id, {
      include: [
        {
          association: 'addedByUser',
          attributes: ['id', 'name']
        }
      ]
    });
    if (!book) return res.status(404).json({ message: "Book not found" });
    res.json(book);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// POST create a new book (admin only)
exports.createBook = async (req, res) => {
  const { title, author, genre, isbn, barcode, description, quantity, coverImage, status } = req.body;

  console.log("📚 Creating book with data:", req.body);

  try {
    const bookExists = await Book.findOne({ where: { isbn } });
    if (bookExists) return res.status(400).json({ message: "ISBN already exists" });

    // Vérifier si le barcode existe déjà (si fourni)
    if (barcode) {
      const barcodeExists = await Book.findOne({ where: { barcode } });
      if (barcodeExists) return res.status(400).json({ message: "Barcode already exists" });
    }

    let coverImagePath = "";
    if (coverImage) {
      coverImagePath = saveBase64Image(coverImage);
    }

    const book = await Book.create({
      title,
      author,
      genre,
      isbn,
      barcode: barcode || null, // Sauvegarder comme null si non fourni
      description,
      quantity: quantity || 1, // Quantité par défaut si non fournie
      coverImagePath,
      status,
      addedBy: req.user.id,
    });

    res.status(201).json(book);
  } catch (err) {
    console.error("❌ Error creating book:", err);
    res.status(500).json({ message: err.message });
  }
};

// PUT update a book (admin only)
exports.updateBook = async (req, res) => {
  try {
    const { coverImage, ...updateData } = req.body;

    if (coverImage) {
      updateData.coverImagePath = saveBase64Image(coverImage);
    }

    const book = await Book.findByPk(req.params.id);
    if (!book) return res.status(404).json({ message: "Book not found" });

    await book.update(updateData);
    res.json(book);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// DELETE a book (admin only)
exports.deleteBook = async (req, res) => {
  try {
    const book = await Book.findByPk(req.params.id);
    if (!book) return res.status(404).json({ message: "Book not found" });

    await book.destroy();
    res.json({ message: "Book deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
