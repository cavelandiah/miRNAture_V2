import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "script" / "evaluate_conserved_str.py"

spec = importlib.util.spec_from_file_location("evaluate_conserved_str", SCRIPT)
evaluate_conserved_str = importlib.util.module_from_spec(spec)
spec.loader.exec_module(evaluate_conserved_str)


class EvaluateConservedStructureTests(unittest.TestCase):
    def test_evaluate_if_no_structure(self):
        self.assertEqual(evaluate_conserved_str.evaluate_if_no_structure("...."), 1)
        self.assertEqual(evaluate_conserved_str.evaluate_if_no_structure("..((..))"), 0)
        self.assertEqual(evaluate_conserved_str.evaluate_if_no_structure(""), 1)

    def test_clean_block_tail(self):
        self.assertEqual(evaluate_conserved_str.clean_block_tail("(((...", "("), "(((")
        self.assertEqual(evaluate_conserved_str.clean_block_tail("(((..((", "("), "(((..((")
        self.assertEqual(evaluate_conserved_str.clean_block_tail(")))....", ")"), ")))")

    def test_validate_folding_mirna(self):
        self.assertEqual(
            evaluate_conserved_str.validate_folding_miRNA("(" * 17, ")" * 17),
            "Valid_All",
        )
        self.assertEqual(
            evaluate_conserved_str.validate_folding_miRNA("(" * 18, ")" * 17),
            "No_valid_No_match",
        )
        self.assertEqual(
            evaluate_conserved_str.validate_folding_miRNA("(" * 16, ")" * 16),
            "No_valid_Short",
        )


if __name__ == "__main__":
    unittest.main()
