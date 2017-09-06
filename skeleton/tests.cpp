/*
 * Copyright (c) 2017, Respective Authors.
 *
 * The MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include <boost/test/unit_test.hpp>

#include <eos/chain/chain_controller.hpp>
#include <eos/chain/exceptions.hpp>
#include <eos/chain/account_object.hpp>
#include <eos/chain/key_value_object.hpp>
#include <eos/chain/block_summary_object.hpp>

#include <eos/utilities/tempdir.hpp>

#include <fc/crypto/digest.hpp>

#include <boost/asio/buffer.hpp>

#include "testing/database_fixture.hpp"
#include "currency.wast.hpp"

using namespace eos;
using namespace chain;

BOOST_AUTO_TEST_SUITE(currency_tests)

BOOST_FIXTURE_TEST_CASE(currency_test, testing_fixture) {
   try {
      Make_Blockchain(chain);
      chain.set_skip_transaction_signature_checking(false);
      chain.set_auto_sign_transactions(true);

      Make_Account(chain, currency);
      Make_Account(chain, user);
      chain.produce_blocks();
      Set_Code(chain, currency, currency_wast);

      SignedTransaction trx;
      trx.scope = sort_names({"currency", "user"});
      trx.expiration = chain.head_block_time() + 100;
      transaction_set_reference_block(trx, chain.head_block_id());

      // TODO: put a transfer message in the transaction.
      // How?

      chain.push_transaction(trx);
   } FC_LOG_AND_RETHROW()
}

BOOST_AUTO_TEST_SUITE_END()
