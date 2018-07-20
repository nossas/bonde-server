def stub_donation_service
  expect(DonationService).to receive(:run).with(anything, anything)
end

def stub_recurrent_service
  expect(SubscriptionService).to receive(:run).with(anything)
end

def stub_create_plans
  expect(SubscriptionService).to receive(:find_or_create_plans).with(anything)
end

def stub_create_transaction
  expect(DonationService).to receive(:new_transaction).with(donation)
end
