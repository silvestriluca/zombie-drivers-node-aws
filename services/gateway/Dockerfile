FROM node:16
# Create microservice directory
WORKDIR /usr/src/microservice
# Install microservice dependencies
COPY package*.json ./
# Install dependencies
RUN npm ci --only=production
# Bundle microservice source
COPY . .
# Open ports
EXPOSE 3000
# Starts service
CMD [ "node", "server.js" ]
