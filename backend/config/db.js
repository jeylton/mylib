const { Sequelize, Op } = require('sequelize');

// Configuration Supabase
const sequelize = new Sequelize({
  dialect: 'postgres',
  host: 'bizagzkozzlhccuhispm.supabase.co',
  port: 5432,
  username: 'postgres',
  password: 'sb_publishable_gpXUVZOv5BDWuLfr-VgpxQ_x_Qh8geb',
  database: 'postgres',
  logging: console.log,
  dialectOptions: {
    ssl: {
      require: true,
      rejectUnauthorized: false
    }
  },
  pool: {
    max: 10,
    min: 0,
    acquire: 30000,
    idle: 10000
  }
});

const connectDB = async () => {
  try {
    await sequelize.authenticate();
    console.log("Supabase connected successfully");
    
    // 🔒 Désactiver la synchronisation automatique pour Docker
    // await sequelize.sync({ alter: true });
    console.log("Database synchronized (sync disabled)");
  } catch (error) {
    console.error("Unable to connect to PostgreSQL:", error.message);
    console.error("Full error:", error);
    process.exit(1);
  }
};

module.exports = { sequelize, Op, connectDB };
