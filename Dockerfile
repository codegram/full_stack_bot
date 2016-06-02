FROM marcelocg/phoenix

ENV MIX_ENV prod
ENV NODE_ENV production

COPY mix.* /code/

COPY apps/bot_engine/mix.* /code/apps/bot_engine/
COPY apps/web_interface/mix.* /code/apps/bot_engine/
COPY apps/web_interface/package.json /code/apps/web_interface/

RUN yes | mix deps.get
RUN yes | mix deps.compile

RUN cd /code/apps/web_interface && npm install

COPY . /code
RUN cd /code/apps/web_interface && npm run compile
RUN cd /code/apps/web_interface && mix phoenix.digest

CMD mix phoenix.server
