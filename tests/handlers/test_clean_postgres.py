"""Tests for clean_postgres.py."""

import pytest

# TODO enable when new test(s) will be added
# from f8a_jobs.handlers.clean_postgres import CleanPostgres


class TestCleanPostgres(object):
    """Tests for CleanPostgres class."""

    def setup_method(self, method):
        """Set up any state tied to the execution of the given method in a class."""
        assert method

    def teardown_method(self, method):
        """Teardown any state that was previously setup with a setup_method call."""
        assert method
