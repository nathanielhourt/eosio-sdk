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

#include <eos/types/AbiSerializer.hpp>

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
      // Create the chain, configure testing options
      Make_Blockchain(chain);
      chain.set_skip_transaction_signature_checking(false);
      chain.set_auto_sign_transactions(true);

      // Create some accounts to work with, and publish the code
      Make_Account(chain, currency);
      Make_Account(chain, user);
      chain.produce_blocks();
      Set_Code(chain, currency, currency_wast, currency_abi);

      auto serial = types::AbiSerializer(fc::json::from_string(currency_abi).as<types::Abi>());

      // Transfer 500 tokens from currency to user
      SignedTransaction trx;
      trx.scope = sort_names({"currency", "user"});
      trx.expiration = chain.head_block_time() + 100;
      auto serialMessage = chain.message_to_binary("currency", "transfer",
                                                   fc::mutable_variant_object("from", "currency")
                                                                             ("to", "user")
                                                                             ("quantity", 500));
      transaction_emplace_serialized_message(trx, "currency", "transfer",
                                             vector<types::AccountPermission>{{"currency", "active"}},
                                             serialMessage);
      transaction_set_reference_block(trx, chain.head_block_id());
      chain.push_transaction(trx);

      auto userRecord = chain_db.get<key_value_object, by_scope_primary>(boost::make_tuple("user", "currency",
                                                                                           "account", "account"));
      auto userBalance = serial.binaryToVariant("UInt64", {userRecord.value.begin(), userRecord.value.end()});
      BOOST_CHECK_EQUAL(userBalance.as_uint64(), 500);
   } FC_LOG_AND_RETHROW()
}

BOOST_AUTO_TEST_SUITE_END()
