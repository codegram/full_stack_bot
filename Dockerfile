FROM marcelocg/phoenix

ENV MIX_ENV prod
ENV NODE_ENV production

COPY mix.exs /code/
COPY mix.lock /code/
COPY config /code/

COPY apps/bot_engine/mix.exs /code/apps/bot_engine/
COPY apps/bot_engine/config /code/apps/bot_engine/config

COPY apps/web_interface/mix.exs /code/apps/web_interface/
COPY apps/web_interface/config /code/apps/web_interface/config
COPY apps/web_interface/package.json /code/apps/web_interface/package.json

RUN yes | mix deps.get
RUN yes | mix deps.compile

RUN cd /code/apps/web_interface && npm install

COPY . /code

RUN cd /code/apps/web_interface && npm run compile
RUN cd /code/apps/web_interface && mix phoenix.digest

CMD mix phoenix.server
