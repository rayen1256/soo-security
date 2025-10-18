const express = require('express');
const session = require('express-session');
const Keycloak = require('keycloak-connect');
const path = require('path');

const app = express();

// Configuration de la session
const memoryStore = new session.MemoryStore();
app.use(session({
  secret: 'portalSecret',
  resave: false,
  saveUninitialized: true,
  store: memoryStore
}));

// Configuration Keycloak
const keycloak = new Keycloak({
  store: memoryStore
}, {
  realm: 'sso-realm',
  'auth-server-url': 'http://localhost',
  'ssl-required': 'none',
  resource: 'portal-app',
  'confidential-port': 0,
  'public-client': true
});

app.use(keycloak.middleware());

// Configuration EJS
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Applications disponibles
const applications = [
  {
    name: 'Django',
    description: 'Framework web Python',
    category: 'Backend',
    url: 'https://www.djangoproject.com',
    technology: 'Python'
  },
  {
    name: 'React',
    description: 'Bibliothèque JavaScript',
    category: 'Frontend',
    url: 'https://reactjs.org',
    technology: 'JavaScript'
  },
  {
    name: 'Java',
    description: 'Platforme de développement',
    category: 'Backend',
    url: 'https://www.java.com',
    technology: 'Java'
  },
  {
    name: 'PHP',
    description: 'Langage de script serveur',
    category: 'Backend',
    url: 'https://www.php.net',
    technology: 'PHP'
  }
];

// Routes
app.get('/', keycloak.protect(), (req, res) => {
  const token = req.kauth.grant.access_token;
  const user = {
    username: token.content.preferred_username,
    email: token.content.email,
    firstName: token.content.given_name,
    lastName: token.content.family_name,
    roles: token.content.realm_access.roles
  };

  // Grouper par catégorie
  const appsByCategory = applications.reduce((acc, app) => {
    if (!acc[app.category]) acc[app.category] = [];
    acc[app.category].push(app);
    return acc;
  }, {});

  res.render('dashboard', {
    user: user,
    applications: appsByCategory,
    title: 'Portail des Technologies'
  });
});

app.get('/public', (req, res) => {
  res.render('public', {
    applications: applications,
    title: 'Portail des Technologies'
  });
});

app.get('/logout', (req, res) => {
  const logoutUrl = `http://localhost/realms/sso-realm/protocol/openid-connect/logout`;
  res.redirect(logoutUrl);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Portail démarré sur le port ${PORT}`);
});