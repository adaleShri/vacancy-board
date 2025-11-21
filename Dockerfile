# ----- Build stage -----
FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
# If you have a build step (React, etc.)
# RUN npm run build

# ----- Runtime stage -----
FROM node:18-alpine

WORKDIR /app

COPY --from=build /app ./

# If it's a front-end only build, you might use a static server instead
# For simple backend:
ENV NODE_ENV=production
EXPOSE 3000

CMD ["npm", "start"]
