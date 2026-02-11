const express = require('express');
const cors = require('cors');
const https = require('https');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Configuration Supabase
const SUPABASE_URL = 'bizagzkozzlhccuhispm.supabase.co';
const SUPABASE_KEY = 'sb_publishable_gpXUVZOv5BDWuLfr-VgpxQ_x_Qh8geb';

// Activities tracking (in memory for demo)
let activities = [];

// Helper function to add activity
function addActivity(action, description, bookTitle = null, userName = null) {
  const activity = {
    id: activities.length + 1,
    action,
    description,
    bookTitle,
    userName,
    date: new Date().toISOString()
  };
  activities.unshift(activity); // Add to beginning
  // Keep only last 50 activities
  if (activities.length > 50) {
    activities = activities.slice(0, 50);
  }
  return activity;
}

// Fonction pour faire des requêtes à Supabase
function supabaseRequest(path, method = 'GET', data = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: SUPABASE_URL,
      port: 443,
      path: `/rest/v1${path}`,
      method: method,
      headers: {
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`,
        'Content-Type': 'application/json'
      }
    };

    // Ajouter Prefer pour les opérations d'écriture
    if (method !== 'GET') {
      options.headers['Prefer'] = 'return=representation';
    }

    const req = https.request(options, (res) => {
      let responseData = '';
      res.on('data', (chunk) => responseData += chunk);
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(responseData);
          resolve({ status: res.statusCode, data: jsonData });
        } catch (e) {
          resolve({ status: res.statusCode, data: responseData });
        }
      });
    });

    req.on('error', reject);

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

// Route de login
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    console.log(`Tentative de connexion: ${email}`);

    // Chercher l'utilisateur dans Supabase
    const response = await supabaseRequest(`/users?email=eq.${email}`);

    if (response.status !== 200 || response.data.length === 0) {
      console.log('Utilisateur non trouvé');
      return res.status(400).json({ message: "Invalid email or password" });
    }

    const user = response.data[0];
    console.log(`Utilisateur trouvé: ${user.name} (${user.role})`);

    // Comparaison directe des mots de passe
    if (password !== user.password) {
      console.log('Mot de passe incorrect');
      return res.status(400).json({ message: "Invalid email or password" });
    }

    // Générer JWT
    const jwt = require('jsonwebtoken');
    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '7d' }
    );

    console.log('Connexion réussie !');

    res.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error('Erreur login:', error);
    res.status(500).json({ message: "Internal server error" });
  }
});

// Route d'inscription
app.post('/api/auth/register', async (req, res) => {
  const { name, email, password, role = 'student' } = req.body;

  try {
    console.log(`Tentative d'inscription: ${email}`);

    // Vérifier si l'utilisateur existe déjà
    const existingUser = await supabaseRequest(`/users?email=eq.${email}`);

    if (existingUser.status === 200 && existingUser.data.length > 0) {
      return res.status(400).json({ message: "Email already exists" });
    }

    // Créer le nouvel utilisateur
    const newUser = {
      name,
      email,
      password, // En clair pour simplifier
      role,
      email_verified: true
    };

    const response = await supabaseRequest('/users', 'POST', newUser);

    if (response.status === 201) {
      console.log('Inscription réussie !');
      res.status(201).json({
        message: "User created successfully",
        user: response.data[0]
      });
    } else {
      res.status(400).json({ message: "Failed to create user" });
    }
  } catch (error) {
    console.error('Erreur inscription:', error);
    res.status(500).json({ message: "Internal server error" });
  }
});

// Route de test
app.get('/api/test', (req, res) => {
  res.json({
    message: '🚀 Supabase Library System is running!',
    timestamp: new Date(),
    version: '1.0.0'
  });
});

// Routes pour les livres
app.get('/api/books', async (req, res) => {
  try {
    const { search } = req.query;
    let path = '/books';

    if (search) {
      // Recherche par titre, auteur ou genre
      path = `/books?or=(title.ilike.*${search}*,author.ilike.*${search}*,genre.ilike.*${search}*)`;
    }

    const response = await supabaseRequest(path);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ message: "Error fetching books" });
  }
});

app.post('/api/books', async (req, res) => {
  try {
    // Nettoyer les données pour ne garder que les colonnes existantes
    const { title, author, isbn, quantity, borrowed_count } = req.body;

    const bookData = {
      title,
      author,
      isbn,
      quantity: quantity || 1,
      borrowed_count: borrowed_count || 0
    };

    const response = await supabaseRequest('/books', 'POST', bookData);
    
    // Add activity for book creation
    addActivity('Book Created', `New book "${title}" was added to library`, title);
    
    res.status(201).json(response.data);
  } catch (error) {
    res.status(500).json({ message: "Error creating book" });
  }
});

app.put('/api/books/:id', async (req, res) => {
  try {
    // Nettoyer les données pour ne garder que les colonnes existantes
    const { title, author, isbn, quantity, borrowed_count } = req.body;

    const updateData = {};
    if (title !== undefined) updateData.title = title;
    if (author !== undefined) updateData.author = author;
    if (isbn !== undefined) updateData.isbn = isbn;
    if (quantity !== undefined) updateData.quantity = quantity;
    if (borrowed_count !== undefined) updateData.borrowed_count = borrowed_count;

    const response = await supabaseRequest(`/books?id=eq.${req.params.id}`, 'PATCH', updateData);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ message: "Error updating book" });
  }
});

app.delete('/api/books/:id', async (req, res) => {
  try {
    // Get book info before deletion for activity log
    const bookResponse = await supabaseRequest(`/books?id=eq.${req.params.id}`);
    const bookTitle = bookResponse.data[0]?.title || 'Unknown book';
    
    // D'abord supprimer tous les emprunts associés à ce livre
    const borrowingsResponse = await supabaseRequest(`/borrowings?book_id=eq.${req.params.id}`, 'DELETE');

    // Ensuite supprimer le livre
    const response = await supabaseRequest(`/books?id=eq.${req.params.id}`, 'DELETE');

    // Add activity for book deletion
    addActivity('Book Deleted', `Book "${bookTitle}" was removed from library`, bookTitle);

    res.json({
      success: true,
      message: "Book and associated borrowings deleted successfully",
      borrowingsDeleted: borrowingsResponse.data,
      bookDeleted: response.data
    });
  } catch (error) {
    console.error('Delete error:', error);
    res.status(500).json({
      success: false,
      message: "Error deleting book",
      error: error.message
    });
  }
});

// Routes pour les emprunts
app.get('/api/borrowings', async (req, res) => {
  try {
    const response = await supabaseRequest('/borrowings');
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ message: "Error fetching borrowings" });
  }
});

app.get('/api/borrowings/user/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;

    const [borrowingsResponse, booksResponse, usersResponse] = await Promise.all([
      supabaseRequest(`/borrowings?user_id=eq.${userId}&order=borrow_date.desc`),
      supabaseRequest('/books'),
      supabaseRequest('/users'),
    ]);

    const borrowings = borrowingsResponse.data || [];
    const books = booksResponse.data || [];
    const users = usersResponse.data || [];

    const user = users.find((u) => String(u.id) === String(userId));

    const enriched = borrowings.map((b) => {
      const book = books.find((bk) => String(bk.id) === String(b.book_id));
      return {
        id: b.id,
        status: b.status,
        borrow_date: b.borrow_date,
        due_date: b.due_date,
        return_date: b.return_date,
        book: book || { id: b.book_id, title: 'Unknown', author: null },
        user: user || { id: b.user_id, name: 'Unknown', email: null },
      };
    });

    res.json(enriched);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching user borrowings' });
  }
});

app.post('/api/borrowings', async (req, res) => {
  try {
    const { user_id, book_id, due_date } = req.body;

    // Vérifier si le livre est disponible
    const bookResponse = await supabaseRequest(`/books?id=eq.${book_id}`);
    const book = bookResponse.data[0];

    if (!book || book.quantity <= book.borrowed_count) {
      return res.status(400).json({ message: "Book not available" });
    }

    // Créer l'emprunt
    const borrowingData = {
      user_id,
      book_id,
      borrow_date: new Date(),
      due_date: due_date || new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 jours par défaut
      status: 'active'
    };

    const response = await supabaseRequest('/borrowings', 'POST', borrowingData);

    // Mettre à jour le nombre d'exemplaires empruntés et le statut
    const newBorrowedCount = book.borrowed_count + 1;
    const isFullyBorrowed = newBorrowedCount >= book.quantity;

    await supabaseRequest(`/books?id=eq.${book_id}`, 'PATCH', {
      borrowed_count: newBorrowedCount,
      status: isFullyBorrowed ? 'borrowed' : 'available'
    });

    // Get user info for activity log
    const userResponse = await supabaseRequest(`/users?id=eq.${user_id}`);
    const userName = userResponse.data[0]?.name || 'Unknown user';

    // Add activity for book borrowing
    addActivity('Book Borrowed', `${userName} borrowed "${book.title}"`, book.title, userName);

    res.status(201).json(response.data);
  } catch (error) {
    res.status(500).json({ message: "Error creating borrowing" });
  }
});

app.put('/api/borrowings/:id/return', async (req, res) => {
  try {
    const borrowingId = req.params.id;

    // Récupérer l'emprunt
    const borrowingResponse = await supabaseRequest(`/borrowings?id=eq.${borrowingId}`);
    const borrowing = borrowingResponse.data[0];

    if (!borrowing) {
      return res.status(404).json({ message: "Borrowing not found" });
    }

    // Vérifier si en retard
    const isOverdue = new Date() > new Date(borrowing.due_date);
    let fineAmount = 0;

    if (isOverdue) {
      const daysOverdue = Math.ceil((new Date() - new Date(borrowing.due_date)) / (1000 * 60 * 60 * 24));
      fineAmount = daysOverdue * 100; // 100 francs par jour de retard

      // Créer une amende
      if (fineAmount > 0) {
        await supabaseRequest('/fines', 'POST', {
          user_id: borrowing.user_id,
          amount: fineAmount,
          reason: `Retard de ${Math.ceil((new Date() - new Date(borrowing.due_date)) / (1000 * 60 * 60 * 24))} jours`,
          status: 'unpaid'
        });
      }
    }

    // Mettre à jour l'emprunt
    await supabaseRequest(`/borrowings?id=eq.${borrowingId}`, 'PATCH', {
      status: 'returned',
      return_date: new Date()
    });

    // Mettre à jour le nombre d'exemplaires empruntés et le statut
    const bookResponse = await supabaseRequest(`/books?id=eq.${borrowing.book_id}`);
    const book = bookResponse.data[0];
    const newBorrowedCount = Math.max(0, book.borrowed_count - 1);

    await supabaseRequest(`/books?id=eq.${borrowing.book_id}`, 'PATCH', {
      borrowed_count: newBorrowedCount,
      status: newBorrowedCount > 0 ? 'borrowed' : 'available'
    });

    // Get user info for activity log
    const userResponse = await supabaseRequest(`/users?id=eq.${borrowing.user_id}`);
    const userName = userResponse.data[0]?.name || 'Unknown user';

    // Add activity for book returning
    addActivity('Book Returned', `${userName} returned "${book.title}"`, book.title, userName);

    res.json({
      message: "Book returned successfully",
      fineAmount: fineAmount,
      isOverdue: isOverdue
    });
  } catch (error) {
    res.status(500).json({ message: "Error returning book" });
  }
});

app.put('/api/borrowings/:id/mark-read', async (req, res) => {
  try {
    const borrowingId = req.params.id;

    const borrowingResponse = await supabaseRequest(`/borrowings?id=eq.${borrowingId}`);
    const borrowing = borrowingResponse.data[0];

    if (!borrowing) {
      return res.status(404).json({ message: 'Borrowing not found' });
    }

    await supabaseRequest(`/borrowings?id=eq.${borrowingId}`, 'PATCH', {
      is_read: true,
      updated_at: new Date(),
    });

    res.json({ message: 'Borrowing marked as read' });
  } catch (error) {
    res.status(500).json({ message: 'Error marking as read' });
  }
});

app.put('/api/borrowings/:id/renew', async (req, res) => {
  try {
    const borrowingId = req.params.id;

    const borrowingResponse = await supabaseRequest(`/borrowings?id=eq.${borrowingId}`);
    const borrowing = borrowingResponse.data[0];

    if (!borrowing) {
      return res.status(404).json({ message: 'Borrowing not found' });
    }

    const currentDue = new Date(borrowing.due_date);
    const newDue = new Date(currentDue.getTime() + 7 * 24 * 60 * 60 * 1000);

    await supabaseRequest(`/borrowings?id=eq.${borrowingId}`, 'PATCH', {
      due_date: newDue,
      updated_at: new Date(),
    });

    res.json({ message: 'Borrowing renewed', due_date: newDue });
  } catch (error) {
    res.status(500).json({ message: 'Error renewing borrowing' });
  }
});

// Routes pour les réservations
app.post('/api/reservations', async (req, res) => {
  try {
    const response = await supabaseRequest('/reservations', 'POST', req.body);
    res.status(201).json(response.data);
  } catch (error) {
    res.status(500).json({ message: "Error creating reservation" });
  }
});

app.get('/api/reservations', async (req, res) => {
  try {
    const response = await supabaseRequest('/reservations');
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ message: "Error fetching reservations" });
  }
});

// Endpoint pour marquer un livre comme lu
app.post('/api/books/:id/mark-as-read', async (req, res) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    const jwt = require('jsonwebtoken');
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');

    const bookId = req.params.id;
    const userId = decoded.id;

    // Créer un enregistrement de lecture (simulé pour l'instant)
    const readRecord = {
      user_id: userId,
      book_id: bookId,
      read_date: new Date(),
      status: 'read'
    };

    // Pour l'instant, on utilise la table borrowings avec un statut spécial
    const response = await supabaseRequest('/borrowings', 'POST', {
      ...readRecord,
      status: 'read'
    });

    res.status(201).json({ message: "Book marked as read", data: response.data });
  } catch (error) {
    res.status(500).json({ message: "Error marking book as read" });
  }
});

// Endpoint pour les emprunts étudiants (version simplifiée)
app.post('/api/student/borrow', async (req, res) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    const jwt = require('jsonwebtoken');
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');

    const { book_id } = req.body;
    const userId = decoded.id;

    // Vérifier la disponibilité
    const bookResponse = await supabaseRequest(`/books?id=eq.${book_id}`);
    const book = bookResponse.data[0];

    if (!book || book.quantity <= book.borrowed_count) {
      return res.status(400).json({ message: "Book not available" });
    }

    // Créer l'emprunt
    const borrowingData = {
      user_id: userId,
      book_id,
      borrow_date: new Date(),
      due_date: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 jours
      status: 'active'
    };

    const response = await supabaseRequest('/borrowings', 'POST', borrowingData);

    // Mettre à jour le livre
    await supabaseRequest(`/books?id=eq.${book_id}`, 'PATCH', {
      borrowed_count: book.borrowed_count + 1
    });

    res.status(201).json({ message: "Book borrowed successfully", data: response.data });
  } catch (error) {
    res.status(500).json({ message: "Error borrowing book" });
  }
});

// Endpoint pour les livres en retard
app.get('/api/borrowings/overdue', async (req, res) => {
  try {
    const response = await supabaseRequest('/borrowings?status=eq.active&due_date=lt.' + new Date().toISOString());
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ message: "Error fetching overdue books" });
  }
});

// Endpoint pour les top emprunteurs
app.get('/api/dashboard/admin/overview/top-borrowers', async (req, res) => {
  try {
    const borrowingsResponse = await supabaseRequest('/borrowings');
    const usersResponse = await supabaseRequest('/users');

    const borrowings = borrowingsResponse.data;
    const users = usersResponse.data;

    // Compter les emprunts par utilisateur
    const borrowingCounts = {};
    borrowings.forEach(borrowing => {
      const userId = borrowing.user_id;
      borrowingCounts[userId] = (borrowingCounts[userId] || 0) + 1;
    });

    // Trier et retourner les top 5
    const topBorrowers = Object.entries(borrowingCounts)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 5)
      .map(([userId, count]) => {
        const user = users.find(u => u.id == userId);
        return {
          user: user,
          borrowingCount: count
        };
      });

    res.json(topBorrowers);
  } catch (error) {
    res.status(500).json({ message: "Error fetching top borrowers" });
  }
});

// Routes pour les utilisateurs
app.get('/api/users', async (req, res) => {
  try {
    const response = await supabaseRequest('/users');
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ message: "Error fetching users" });
  }
});

// Routes pour le dashboard admin
app.get('/api/dashboard/admin/overview', async (req, res) => {
  try {
    const usersResponse = await supabaseRequest('/users');
    const booksResponse = await supabaseRequest('/books');
    const borrowingsResponse = await supabaseRequest('/borrowings');
    const finesResponse = await supabaseRequest('/fines');

    const users = usersResponse.data;
    const books = booksResponse.data;
    const borrowings = borrowingsResponse.data;
    const fines = finesResponse.data;

    // Calculs selon les spécifications
    const totalUsers = users.length;
    const totalBooks = books.length;
    const totalBorrowings = borrowings.filter((b) => b.status === 'active').length;
    const totalBalanceCollected = fines
      .filter(f => f.status === 'paid')
      .reduce((sum, fine) => sum + parseFloat(fine.amount), 0);

    const overview = {
      totalBooks,
      totalUsers,
      totalBorrowings,
      totalBalanceCollected,
      recentUsers: users.slice(-5),
      popularBooks: books.sort((a, b) => b.borrowed_count - a.borrowed_count).slice(0, 3),
      recentBorrowings: borrowings.slice(-5)
    };

    res.json(overview);
  } catch (error) {
    res.status(500).json({ message: "Error fetching admin overview" });
  }
});

// Routes pour le dashboard student
app.get('/api/dashboard/student', async (req, res) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    const jwt = require('jsonwebtoken');
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');

    const userResponse = await supabaseRequest(`/users?id=eq.${decoded.id}`);
    const borrowingsResponse = await supabaseRequest(`/borrowings?user_id=eq.${decoded.id}`);
    const finesResponse = await supabaseRequest(`/fines?user_id=eq.${decoded.id}`);

    const user = userResponse.data[0];
    const borrowings = borrowingsResponse.data;
    const fines = finesResponse.data;

    // Calculs réels avec balance initiale de 2500
    const totalBorrowed = borrowings.length;
    const currentBorrowings = borrowings.filter(b => b.status === 'active').length;
    const totalFines = fines.reduce((sum, fine) => sum + parseFloat(fine.amount), 0);
    const initialBalance = 2500;
    const currentBalance = initialBalance - totalFines;

    const studentData = {
      user: {
        name: user.name,
        email: user.email,
        balance: currentBalance.toFixed(2)
      },
      totalBorrowed,
      currentBorrowings,
      booksRead: borrowings.filter(b => b.is_read).length,
      totalBalance: currentBalance.toFixed(2),
      unpaidFines: fines.filter(f => f.status === 'unpaid').length,
      overdueBorrowings: borrowings.filter(b =>
        b.status === 'active' && new Date(b.due_date) < new Date()
      ),
      recentActivity: borrowings.slice(-5).map(b => ({
        action: b.status === 'active' ? "Borrowed" : "Returned",
        book: `Book ID: ${b.book_id}`,
        date: b.borrow_date
      }))
    };

    res.json(studentData);
  } catch (error) {
    res.status(500).json({ message: "Error fetching student dashboard" });
  }
});

// Endpoint pour récupérer les activités
app.get('/api/activities', (req, res) => {
  try {
    res.json({
      success: true,
      activities: activities.slice(0, 20) // Return last 20 activities
    });
  } catch (error) {
    res.status(500).json({ message: "Error fetching activities" });
  }
});

// Démarrage du serveur
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Serveur Supabase démarré sur le port ${PORT}`);
  console.log(`📊 Test: http://localhost:${PORT}/api/test`);
  console.log(`🔐 Login: http://localhost:${PORT}/api/auth/login`);
  console.log(`📝 Register: http://localhost:${PORT}/api/auth/register`);
  console.log(`🌐 Frontend: Ouvre build/web/index.html`);
});
