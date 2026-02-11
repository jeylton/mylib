@echo off
echo 🧪 Test de LibroFlow Docker...

echo.
echo 📊 État des conteneurs:
docker-compose ps

echo.
echo 🌐 Test Frontend (http://localhost:3000):
curl -s -o nul -w "Status: %%{http_code}\n" http://localhost:3000

echo.
echo 🔧 Test Backend API (http://localhost:5001):
echo   - Books API:
curl -s -o nul -w "Status: %%{http_code}\n" http://localhost:5001/api/books

echo.
echo   - Auth Login Test:
curl -s -o nul -w "Status: %%{http_code}\n" http://localhost:5001/api/auth/login -X POST -H "Content-Type: application/json" -d "{\"email\":\"test@test.com\",\"password\":\"test\"}"

echo.
echo 🗄️ Test Base de Données:
netstat -an | findstr :5432 >nul && echo ✅ PostgreSQL accessible || echo ❌ PostgreSQL inaccessible

echo.
echo 📋 Logs récents:
echo --- Backend ---
docker-compose logs --tail=5 backend
echo --- Frontend ---
docker-compose logs --tail=5 frontend
echo --- PostgreSQL ---
docker-compose logs --tail=5 postgres

echo.
echo ✅ Tests terminés !
pause
