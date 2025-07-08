#! /bin/bash

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Building native release...${NC}"
odin build src/ -target:linux_amd64 -o:speed -out:linux/tesuteru
echo -e "${GREEN}Done.${NC}"

echo -e "${GREEN}Building x86_64-pc-windows-gnu release...${NC}"
odin build src/ -target:windows_amd64 -o:speed -linker:lld -out:windows/tesuteru.exe
echo -e "${GREEN}Done.${NC}"
