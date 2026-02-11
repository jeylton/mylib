const { sequelize } = require('../config/db');
const User = require('../models/user.model');

async function updateAllUserBalances() {
  try {
    console.log('🔄 Mise à jour des balances des utilisateurs...');
    
    // Mettre à jour tous les utilisateurs sauf les admins
    const [updatedCount] = await User.update(
      { balance: 2500.00 },
      { 
        where: { 
          role: { [sequelize.Sequelize.Op.ne]: 'admin' } // role != 'admin'
        }
      }
    );

    console.log(`✅ ${updatedCount} utilisateurs étudiants mis à jour avec 2500F de balance`);
    
    // Vérifier les admins pour s'assurer qu'ils n'ont pas de balance
    const adminCount = await User.count({
      where: { role: 'admin' }
    });
    
    console.log(`📊 ${adminCount} comptes admin trouvés (balance inchangée)`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Erreur lors de la mise à jour:', error);
    process.exit(1);
  }
}

updateAllUserBalances();
