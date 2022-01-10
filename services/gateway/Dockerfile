# Dockerfile implementing Node best practices -> 
# https://snyk.io/blog/10-best-practices-to-containerize-nodejs-web-applications-with-docker/
FROM node:16.13.1
# Install dumb-init (5. Properly handle events to safely terminate a Node.js Docker web application)
RUN apt-get -y update && apt-get install -qqy dumb-init
# Set env variable to production
ENV NODE_ENV production
# Create microservice directory
WORKDIR /usr/src/microservice
# Install microservice dependencies
COPY --chown=node:node package*.json ./
# Install dependencies
RUN npm ci --only=production
# Bundle microservice source
COPY --chown=node:node . .
# Open ports
EXPOSE 3000
# Set env variables
ENV PORT=3000
ENV HOST=0.0.0.0
# Starts service
USER node
CMD [ "dumb-init", "node", "server.js" ]
