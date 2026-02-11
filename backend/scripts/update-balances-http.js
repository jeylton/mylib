// Script pour mettre à jour les balances via une requête HTTP
const http = require('http');

const updateBalances = async () => {
  try {
    console.log('🔄 Mise à jour des balances des utilisateurs...');
    
    // Options pour la requête HTTP
    const options = {
      hostname: 'localhost',
      port: 5000,
      path: '/api/fines/update-all-balances',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer admin-token-placeholder'
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        console.log('✅ Réponse du serveur:', data);
      });
    });

    req.on('error', (error) => {
      console.error('❌ Erreur:', error.message);
    });

    req.end();
  } catch (error) {
    console.error('❌ Erreur lors de la mise à jour:', error);
  }
};

updateBalances();
