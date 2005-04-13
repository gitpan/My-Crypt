# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Crypt.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 2;
BEGIN { use_ok('My::Crypt') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $c = My::Crypt->new(debug => 0, encoding => 'hex8');

my $enc = $c->encrypt('plain text to encrypt', 'mysecret');

my $dec = $c->decrypt($enc, 'mysecret');

ok($dec eq 'plain text to encrypt', 'Encryption / Decryption');

