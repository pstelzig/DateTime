import unittest
import pathlib
from mopyregtest import RegressionTest

this_folder = pathlib.Path(__file__).absolute().parent
package_folder = this_folder / "../src/DateTime"
result_folder = this_folder / "results"

class TestDatetimeRepetition(unittest.TestCase):
    def test_TestAddRepetition(self):
        model_name = "DateTime.Examples.UnitTests.Repetition.TestAddRepetition"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

    def test_TestLargestPreviousTrigger(self):
        model_name = "DateTime.Examples.UnitTests.Repetition.TestLargestPreviousTrigger"
        tester = RegressionTest(package_folder=package_folder,
                                model_in_package=model_name,
                                result_folder=result_folder)
        tester.check_success()
        #tester.cleanup(ask_confirmation=False)

if __name__ == '__main__':
    unittest.main()
