import '../models/package_model.dart';

class MockDataService {
  static final List<TravelPackage> mockPackages = [
    TravelPackage(
      id: '1',
      name: 'andi puri',
      imageUrl: 'https://images.unsplash.com/photo-1596329486780-87a1d7c3b9dd?auto=format&fit=crop&w=800&q=80',
      price: 5000,
      rating: 4.8,
      duration: '3 Days',
      location: 'Kerala',
    ),
    TravelPackage(
      id: '2',
      name: 'Goa Beach Party',
      imageUrl: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=800&q=80',
      price: 8000,
      rating: 4.5,
      duration: '4 Days',
      location: 'Goa',
    ),
    TravelPackage(
      id: '3',
      name: 'Wayanad Escape',
      imageUrl: 'https://images.unsplash.com/photo-1590050752117-238cb0fb12b1?auto=format&fit=crop&w=800&q=80',
      price: 4500,
      rating: 4.7,
      duration: '2 Days',
      location: 'Kerala',
    ),
    TravelPackage(
      id: '4',
      name: 'Jaipur Royals',
      imageUrl: 'https://images.unsplash.com/photo-1477587458883-47145ed94245?auto=format&fit=crop&w=800&q=80',
      price: 12000,
      rating: 4.9,
      duration: '5 Days',
      location: 'Rajasthan',
    ),
    TravelPackage(
      id: '5',
      name: 'Manali Snow Trek',
      imageUrl: 'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=800&q=80',
      price: 15000,
      rating: 4.6,
      duration: '6 Days',
      location: 'Himachal Pradesh',
    ),
    TravelPackage(
      id: '6',
      name: 'Ooty Tea Gardens',
      imageUrl: 'https://images.unsplash.com/photo-1582239478431-7e874932aa9c?auto=format&fit=crop&w=800&q=80',
      price: 6000,
      rating: 4.4,
      duration: '3 Days',
      location: 'Tamil Nadu',
    ),
  ];
}
