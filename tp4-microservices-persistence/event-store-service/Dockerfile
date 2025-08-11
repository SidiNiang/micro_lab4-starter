FROM node:18-alpine

WORKDIR /app

# Copier package.json uniquement
COPY package.json ./

# Installer les dépendances et générer package-lock.json
RUN npm install --production

# Copier le code source
COPY src ./src

EXPOSE 3001

CMD ["npm", "start"]
