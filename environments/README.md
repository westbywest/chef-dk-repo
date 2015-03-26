Requires Chef 0.10.0+.

This directory is for Ruby DSL and JSON files for environments. For more information see "About Environments" in the Chef documentation:

The production.json environment is provided for demonstation purposes.  Notes about this environment:

* Using postgres cookbook with chef-zero requires specifying a root password in the environment file (wrapped in an MD5 hash).  This hash is best hidden from public Github view using an encrypted data bag, or by excluding your enviromnent file from Github altogether.  The MD5 hash can be created at the command line via
```
echo -n 'areallygoodpassword''postgres' | openssl md5 | sed -e 's/.* /md5/'
```

http://docs.chef.io/environments.html
