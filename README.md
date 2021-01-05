# Sample Project to display issue when using a Secure Enclave P256 key loaded from keychain. 

The sample project is Apple's own project for illustrating how to store keys in keychain correctly. 
The project can be found here: https://developer.apple.com/documentation/cryptokit/storing_cryptokit_keys_in_the_keychain

## Reproduction Steps
1. Clone this project, change Team in 'Signing & Capabilities' and run the project on your iPhone that supports Secure Enclave (I'm Running on an iPhone Xs 64GB, v14.3)
2. In the app, click the `Initialise Keys` button. This will initialise 3 Secure Enclave pairs and store them as variables: 
    - Two directly generated using Secure Enclave
    - One loaded by storing a Secure Enclave pair in keychain and reading it out again. 
    Next, it will compute two shared secrets; one between the two directly generated pairs and another between the key from keychain and one directly generated pair.
3. Click `Use Keys - Expected to Succeed`. This will try to compute the two same shared secrets again - but here the key from keychain is read once more from keychian before being used. We *don't* use the one stored as a variable. 
4. Click `Use Keys - Expected to fail`. This will try to compute two same two shared secrets again - but this time it *will* use the key from keychain stored as a variable. 

## Expected Behaviour
I expect step 3 and step 4 to produce the same shared secrets. I expect to be able to use the keypair the same way regardless of it being read from keychain. 

## Actual Behaviour
Step 2 and 3 produce the same shared secrets. But in step 4 we get a `Error Domain=CryptoTokenKit Code=-3 "corrupted objectID detected" UserInfo={NSLocalizedDescription=corrupted objectID detected}`. 

In other words; the key loaded from keychain works as expected *just after* having read it from keychain, but if I store it in a variable and then later make use of key key (as in step 4), I get an error saying the object is corrupted. 

## Changes I Made To The Project
To illustrate this phenomenon, I have extended Apple's sample code project. All changes are found in `ExecutionView.swift` and are clearly marked. 
No other changes have been made. 
