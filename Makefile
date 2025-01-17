fmt:
	npx prettier --write . 
dev: fmt
	nix --extra-experimental-features 'nix-command flakes' --accept-flake-config develop -c npm install && npm run dev
aws-upload:
	tar -czf master-release.tar.gz README.org COPYING build/*
	aws s3 ls
	aws s3 ls s3://carvoeirowaterfun.com/
	aws s3 rm s3://carvoeirowaterfun.com --recursive
	aws s3 cp build s3://carvoeirowaterfun.com/ --recursive
	aws s3 ls s3://carvoeirowaterfun.com/
deploy:
	cd /etc/byggsteg/job-clone/carvoeiro-water-fun/trunk && sudo npm install
	cd /etc/byggsteg/job-clone/carvoeiro-water-fun/trunk && sudo npm run build
	sudo rm -rf /srv/http/carvoeirowaterfun.com/*
	sudo cp -Rf /etc/byggsteg/job-clone/carvoeiro-water-fun/trunk/build/* /srv/http/carvoeirowaterfun.com/
