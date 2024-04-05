FROM dart:3.3.3

WORKDIR /app

COPY . .

RUN dart pub get

RUN dart compile exe bin/main.dart -o server

EXPOSE 4400

CMD [ "/app/server" ]