# How to contribute

This document is a set of guidelines to contribute to the [Rackspace](https://www.rackspace.com) [Terraform](https://www.terraform.io/) modules. These modules were created to enable and empower our Managed Infrastructure as Code product. While these modules are designed for Rackspace environments, we hope they may be of use to the community at large.

## Reporting issues

Rackspace customers should open a normal Rackspace support ticket to report any problems or feedback for these modules. Our support Rackers will then work with you and our product team to address those issues.

## Submitting Changes

Pull requests are welcome. Currently our CI solution cannot run against pull requests from forks.  Despite this, these submissions are still welcome. All pull requests will be evaluated against Rackspace best practices, and after approval, will be migrated to a branch for testing.

For significant or critical features, a new test should be created, or if appropriate, and existing test should be updated.  This will serve to ensure the any failures related to the feature are caught.

When submitting a pull request please explain the changes in detail, and try to minimize the scope to related changes. For example, changes resolving separate bugs should be broken out into separate pull requests. If there are relevant documentation or references, such as terraform bug reports, links to those references are greatly appreciated.

## Testing

Pull requests must pass a linting and build test prior to acceptance. This test ensures all submissions will produce a stable and working deployment. In addition, our CI jobs will run a check_destruction test to help determine if any breaking changes will occur with this change. This test will show a failed result if breaking changes are detected, but this will not prevent the submission from being approved.

## Coding and Style guidelines

All submissions should comply with the coding and style guides outlined at [General Terraform Style Guide](https://manage.rackspace.com/aws/docs/product-guide/miac/terraform-standards.html#general-terraform-style-guide) and [Rackspace Module Standards](https://manage.rackspace.com/aws/docs/product-guide/miac/terraform-standards.html#rackspace-module-). CI testing will run and flag code that does not meet these defined standards whenever possible.
