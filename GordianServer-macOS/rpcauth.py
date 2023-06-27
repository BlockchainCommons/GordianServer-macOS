from base64 import urlsafe_b64encode
from os import urandom

import hmac

def generate_salt(size):
    """Create size byte hex salt"""
    randomSalt = urandom(size)
    return randomSalt.hex()

def generate_password():
    """Create 32 byte b64 password"""
    random = urandom(32)
    return urlsafe_b64encode(random).decode('utf-8')

def password_to_hmac(salt, password):
    m = hmac.new(bytearray(salt, 'utf-8'), bytearray(password, 'utf-8'), 'SHA256')
    return m.hexdigest()

def main(user):
    password = generate_password()

    # Create 16 byte hex salt
    salt = generate_salt(16)
    password_hmac = password_to_hmac(salt, password)

    return ['rpcauth={0}:{1}${2}'.format(user, salt, password_hmac), password]

if __name__ == '__main__':
    main()

