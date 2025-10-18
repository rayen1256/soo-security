#!/bin/bash

echo "🚀 Démarrage de l'initialisation LDAP personnalisée..."

# Attendre que le service LDAP soit complètement démarré
echo "⏳ Attente du démarrage de slapd..."
until ldapsearch -x -H ldap://localhost -b "" -s base > /dev/null 2>&1; do
    echo "⏱️  LDAP non prêt, nouvel essai dans 3 secondes..."
    sleep 3
done

echo "✅ LDAP est démarré!"

# Vérifier si la base de données existe déjà
if ldapsearch -x -H ldap://localhost -b "dc=mondomaine,dc=com" -D "cn=admin,dc=mondomaine,dc=com" -w admin123 2>/dev/null | grep -q "numEntries"; then
    echo "📊 LDAP contient déjà des données, initialisation ignorée."
    exit 0
fi

echo "🆕 Initialisation de la nouvelle base LDAP..."

# Structure de base
cat > /tmp/00-base.ldif << 'EOF'
dn: dc=mondomaine,dc=com
objectClass: top
objectClass: dcObject
objectClass: organization
o: Mon Organisation
dc: mondomaine

dn: cn=admin,dc=mondomaine,dc=com
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP Administrator
userPassword: admin123
EOF

# Unités organisationnelles
cat > /tmp/01-ous.ldif << 'EOF'
dn: ou=users,dc=mondomaine,dc=com
objectClass: organizationalUnit
ou: users

dn: ou=groups,dc=mondomaine,dc=com
objectClass: organizationalUnit
ou: groups

dn: ou=clients,dc=mondomaine,dc=com
objectClass: organizationalUnit
ou: clients
EOF

# Utilisateurs de test
cat > /tmp/02-users.ldif << 'EOF'
dn: uid=user1,ou=users,dc=mondomaine,dc=com
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
uid: user1
cn: Utilisateur Test 1
sn: Test
givenName: Utilisateur
mail: user1@mondomaine.com
userPassword: user123

dn: uid=user2,ou=users,dc=mondomaine,dc=com
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: person
uid: user2
cn: Utilisateur Test 2
sn: Test
givenName: Utilisateur
mail: user2@mondomaine.com
userPassword: user123
EOF

# Importer les données
echo "📥 Importation des données LDIF..."

ldapadd -x -H ldap://localhost -D "cn=admin,dc=mondomaine,dc=com" -w admin123 -f /tmp/00-base.ldif
ldapadd -x -H ldap://localhost -D "cn=admin,dc=mondomaine,dc=com" -w admin123 -f /tmp/01-ous.ldif
ldapadd -x -H ldap://localhost -D "cn=admin,dc=mondomaine,dc=com" -w admin123 -f /tmp/02-users.ldif

# Nettoyer
rm -f /tmp/*.ldif

echo "🎉 Initialisation LDAP terminée avec succès!"
echo "📊 Données créées:"
echo "   - Domaine: dc=mondomaine,dc=com"
echo "   - OUs: users, groups, clients"
echo "   - Utilisateurs: user1, user2"