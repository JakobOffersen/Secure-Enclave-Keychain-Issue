/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The execution view, common to all key types.
*/

import SwiftUI
import CryptoKit // For Secure Enclave

// ----------
// The following code is added by me
// ----------
class KeychainHelper {
    let keychain = GenericPasswordStore()
    let account = "Account Name"

    func keyFromKeychain() -> SecureEnclave.P256.KeyAgreement.PrivateKey {
        if let foundKey: SecureEnclave.P256.KeyAgreement.PrivateKey = try? keychain.readKey(account: account) {
            return foundKey
        } else {
            // Generate a new key and store it in keychain
            let newKey = try! SecureEnclave.P256.KeyAgreement.PrivateKey()
            try! keychain.storeKey(newKey, account: account)
            return try! keychain.readKey(account: account)!
        }
    }
}

var keyFromKeychain: SecureEnclave.P256.KeyAgreement.PrivateKey!
var ephemeralKey1: SecureEnclave.P256.KeyAgreement.PrivateKey!
var ephemeralKey2: SecureEnclave.P256.KeyAgreement.PrivateKey!

func computeSecretsFromVariables() {
    let sharedSecretFromEphemeralKeys = try! ephemeralKey1.sharedSecretFromKeyAgreement(with: ephemeralKey2.publicKey)
    print("Shared Secret of two ephemeral keys: \(sharedSecretFromEphemeralKeys.dataRepresentation)")

    let sharedSecretFromKeychainKeyAndEphemeralKey = try! keyFromKeychain.sharedSecretFromKeyAgreement(with: ephemeralKey1.publicKey)
    print("Shared Secret of keychain-key and ephemeral key: \(sharedSecretFromKeychainKeyAndEphemeralKey.dataRepresentation)")
}

func computeSecretsByLoadingDirectlyFromKeychain() {
    let key = KeychainHelper().keyFromKeychain()
    let sharedSecretFromKeychainKeyAndEphemeralKey = try! key.sharedSecretFromKeyAgreement(with: ephemeralKey1.publicKey)
    print("Shared Secret of keychain-key and ephemeral key: \(sharedSecretFromKeychainKeyAndEphemeralKey.dataRepresentation)")
}

// ----------
// End of code block
// ----------

struct ExecutionView: View {
    @EnvironmentObject var tester: KeyTest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            HStack {
                if tester.status == .pending {
                    Button("Test", action: tester.run)
                } else {
                    Button("Reset", action: tester.reset)
                }
                Spacer()
                Rectangle()
                    .frame(width: 60, height: 30)
                    .cornerRadius(5)
                    .foregroundColor(tester.status == .fail ? .red : (tester.status == .pending ? .clear : .green))
                    .overlay(Text(tester.status.rawValue)
                        .font(Font.body.bold())
                        .foregroundColor(.white)
                    )
            }
            Text(tester.message)
                .lineLimit(20)
            Spacer()
            // The three buttons below are added by me for demonstration purposes
            Button("Initialise Keys") {
                print("'Initialise Keys pressed'")
                keyFromKeychain = KeychainHelper().keyFromKeychain()
                ephemeralKey1 = try! SecureEnclave.P256.KeyAgreement.PrivateKey()
                ephemeralKey2 = try! SecureEnclave.P256.KeyAgreement.PrivateKey()

                print("Keys initialised successfully")
                // Notice how the following function is successful.
                computeSecretsFromVariables()
            }
            Button("Use Keys - Expected to Succeed") {
                computeSecretsByLoadingDirectlyFromKeychain()
            }
            Button("Use Keys - Expected to fail") {
                // And here, the shared secret from two ephemeral keys is successful,
                // but the shared secret of a key from keychain and ephemeral fails with the following error:
                /// Error Domain=CryptoTokenKit Code=-3 "corrupted objectID detected" UserInfo={NSLocalizedDescription=corrupted objectID detected}
                computeSecretsFromVariables()
            }
        }
    }
}
