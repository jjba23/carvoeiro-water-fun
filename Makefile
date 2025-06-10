# Carvoeiro Water Fun

# Copyright © Josep Jesus Bigorra Algaba

# carvoeiro-water-fun is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# carvoeiro-water-fun is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with carvoeiro-water-fun. If not, see <https://www.gnu.org/licenses/>.

define carvoeiro-water-fun-build
	guix shell -m manifest.scm -- \
		guile -L ./src -c '((@(carvoeiro-water-fun main) main))' \
		--locale $(1) --output-dir ./dist --resources-dir ./resources
endef

build-en:
	$(call carvoeiro-water-fun-build,"en_US")
build-pt:
	$(call carvoeiro-water-fun-build,"pt_PT")

serve:
	darkhttpd ./dist --port 50065
dev:
	watchexec -i "dist/**" -r -e scm,css,js -- "make build-en && make serve"
deploy:
	make build-en
	rm -rfv /srv/http/carvoeirowaterfun.com
	cp -rfv dist /srv/http/carvoeirowaterfun.com
	make build-pt
	rm -rfv /srv/http/carvoeirowaterfun.com/pt
	cp -rfv dist /srv/http/carvoeirowaterfun.com/pt
fmt:
	find . -maxdepth 6 -name "*.scm" -type f -exec guix style -f {} \;

# Development REPL
repl:
	guix shell -m manifest.scm -- \
		guile \
		-L ./src \
		-c '((@ (ares server) run-nrepl-server))'
