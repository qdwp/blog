FROM sphinxdoc/sphinx:4.5.0

WORKDIR /docs
ADD requirements.txt /docs
RUN pip3 install -r requirements.txt
