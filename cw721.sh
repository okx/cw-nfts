captain=$(exchaincli keys show captain | jq -r '.eth_address')
admin18=$(exchaincli keys show admin18 | jq -r '.eth_address')


res=$(exchaincli tx wasm store ./artifacts/cw721_base.wasm --instantiate-everybody=true --from captain --fees 0.001okt --gas 3000000 -y -b block)
txhash=$(echo "$res" | jq '.txhash' | sed 's/\"//g')
echo "store-cw721:"$txhash
code_id=$(echo "$res" | jq '.logs[0].events[1].attributes[0].value' | sed 's/\"//g')
res=$(exchaincli tx wasm instantiate "$code_id" '{"minter":"'$captain'","name":"oktestnft","symbol":"oktest"}' --label test1 --admin "$captain" --from captain --fees 0.001okt --gas 3000000  -y -b block)
cw20contractAddr=$(echo "$res" | jq '.logs[0].events[0].attributes[0].value' | sed 's/\"//g')
txhash=$(echo "$res" | jq '.txhash' | sed 's/\"//g')
echo "init-cw20:"$txhash
#res=$(exchaincli query account "$cw20contractAddr" | jq -r '.value.coins[0].amount')
#cw20_balance=$(exchaincli query wasm contract-state smart "$cw20contractAddr" '{"balance":{"address":"'$captain'"}}' | jq '.data.balance' | sed 's/\"//g')
#echo "addr:"$cw20contractAddr,"	acc:"$res,"	balance:"$cw20_balance
#
#

res=$(exchaincli tx wasm execute "$cw20contractAddr" '{"mint":{"token_id":"1","owner":"'$captain'","token_uri":"http://okttest.com"}}' --from captain --fees 0.001okt --gas 3000000  -y -b block)
txhash=$(echo "$res" | jq '.txhash' | sed 's/\"//g')
echo "mint-cw721:"$txhash

res=$(exchaincli query wasm contract-state smart "$cw20contractAddr" '{"nft_info":{"token_id":"1"}}')
owner=$(exchaincli query wasm contract-state smart "$cw20contractAddr" '{"owner_of":{"token_id":"1"}}')
echo "nft_info:"$res,"  owner:"$owner

res=$(exchaincli tx wasm execute "$cw20contractAddr" '{"transfer_nft":{"token_id":"1","recipient":"'$admin18'"}}' --from captain --fees 0.001okt --gas 3000000  -y -b block)
txhash=$(echo "$res" | jq '.txhash' | sed 's/\"//g')
echo "transfer-cw721:"$txhash
res=$(exchaincli query wasm contract-state smart "$cw20contractAddr" '{"nft_info":{"token_id":"1"}}')
owner=$(exchaincli query wasm contract-state smart "$cw20contractAddr" '{"owner_of":{"token_id":"1"}}')
echo "nft_info:"$res,"  owner:"$owner
#echo "exec-cw20:"$txhash
#res=$(exchaincli query account "$cw20contractAddr" | jq -r '.value.coins[0].amount')
#cw20_balance=$(exchaincli query wasm contract-state smart "$cw20contractAddr" '{"balance":{"address":"'$captain'"}}'| jq '.data.balance' | sed 's/\"//g')
#echo "addr:"$cw20contractAddr,"	acc:"$res,"	balance:"$cw20_balance
#
#
#
#cw20_balance=$(exchaincli query wasm contract-state smart "$cw20contractAddr" '{"balance":{"address":"'$admin18'"}}' | jq '.data.balance' | sed 's/\"//g')
#echo "addr:"$admin18,"	acc:---------------------","	balance:"$cw20_balance

