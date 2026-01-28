# syntax=docker/dockerfile:1
# Same as deploy/build/Dockerfile webbuilder stage (exact commands).
FROM public.ecr.aws/docker/library/node:24-trixie
WORKDIR /web
COPY . /web/

RUN npm install
RUN NODE_OPTIONS="--max-old-space-size=8192" npm run build

EXPOSE 8081
CMD ["npx", "serve", "-s", "dist", "-l", "8081"]
