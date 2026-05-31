package org.myfertipal.app

import co.paystack.android.Paystack
import co.paystack.android.PaystackSdk
import co.paystack.android.model.Card
import co.paystack.android.model.Charge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
	private val channelName = "paystack_android"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"initialize" -> {
						val publicKey = call.argument<String>("publicKey")
						if (publicKey.isNullOrBlank()) {
							result.success(false)
							return@setMethodCallHandler
						}

						PaystackSdk.initialize(applicationContext)
						PaystackSdk.setPublicKey(publicKey)
						result.success(true)
					}

					"chargeCard" -> {
						val accessCode = call.argument<String>("accessCode") ?: ""
						val cardNumber = call.argument<String>("cardNumber") ?: ""
						val cvc = call.argument<String>("cvc") ?: ""
						val expMonth = call.argument<Int>("expMonth") ?: 0
						val expYear = call.argument<Int>("expYear") ?: 0
						val email = call.argument<String>("email") ?: ""
						val amountKobo = call.argument<Int>("amountKobo") ?: 0
						val currency = call.argument<String>("currency") ?: "NGN"
						val reference = call.argument<String>("reference") ?: ""

						val card = Card(cardNumber, expMonth, expYear, cvc)
						if (!card.isValid) {
							result.success(
								mapOf(
									"status" to "error",
									"message" to "Invalid card details"
								)
							)
							return@setMethodCallHandler
						}

						val charge = Charge()
						charge.card = card
						charge.email = email
						charge.currency = currency
						if (accessCode.isNotBlank()) {
							charge.accessCode = accessCode
						} else {
							charge.amount = amountKobo
							if (reference.isNotBlank()) {
								charge.reference = reference
							}
						}

						var responded = false
						fun respond(payload: Map<String, String>) {
							if (responded) return
							responded = true
							result.success(payload)
						}

						PaystackSdk.chargeCard(
							this,
							charge,
							object : Paystack.TransactionCallback {
								override fun onSuccess(transaction: co.paystack.android.Transaction) {
									respond(
										mapOf(
											"status" to "success",
											"reference" to transaction.reference
										)
									)
								}

								override fun beforeValidate(transaction: co.paystack.android.Transaction) {
									// No-op: wait for final success/error callback.
								}

								override fun onError(error: Throwable, transaction: co.paystack.android.Transaction?) {
									val message = error.message ?: "Payment failed"
									respond(
										mapOf(
											"status" to "error",
											"message" to message
										)
									)
								}
							}
						)
					}

					else -> result.notImplemented()
				}
			}
	}
}
