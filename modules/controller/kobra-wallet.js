import {KobraWallet as BaseKobraWallet} from '/node_modules/@kobra/ux/kobra-ux.js';

class KobraWallet extends BaseKobraWallet{
	makeFaucetRequest(subject, args){
		let origin = 'https://faucet.kobradag.io';
		//origin = 'http://localhost:3000';
		const {address, amount} = args;
		let path = {
			'faucet-available': `available/${address}`,
			'faucet-request': `get/${address}/${amount}`
		}[subject];

		if(!path)
			return Promise.reject("Invalid request subject:"+subject)

		return fetch(`${origin}/api/${path}`, {
			method: 'GET'
		}).then(res => res.json())
	}
}

KobraWallet.define("kobra-wallet")
