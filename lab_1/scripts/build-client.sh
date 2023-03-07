#!/bin/bash

cd ../../../shop-angular-cloudfront
npm i
if [ -d /dist ] && [ -f client-app.zip ]; then
	rm ./dist/client-app.zip
fi
npm run-script build --configuration
zip -r client-app.zip ./dist/app/
