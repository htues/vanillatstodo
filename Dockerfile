FROM node:18-alpine AS build

WORKDIR /app

COPY package.json yarn.lock ./

RUN yarn install

COPY . .

RUN yarn build

# Step 7: Use a lightweight web server to serve the built files
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

## how to use this file:
# docker build -t hftamayo/vanillatstodo:0.0.1 .
# docker run --name vanillatstodo -p 9090:80 hftamayo/vanillatstodo:0.0.1 -d