def stub_donation_service
  expect(DonationService).to receive(:run).with(anything, anything)
end

def stub_recurrent_service
  expect(SubscriptionService).to receive(:run).with(anything)
end
